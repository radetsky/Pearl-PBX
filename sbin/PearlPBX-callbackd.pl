#!/usr/bin/env perl
#===============================================================================
#         FILE:  PearlPBX-callbackd.pl
#        USAGE:  ./PearlPBX-callbackd.pl [ --verbose ]
#  DESCRIPTION:  Find free operator in CallBack* Queues and connect it to context with CallBack to the user instructions
# REQUIREMENTS:  NewIVR2018 Scenarios
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      CREATED:  2018/11/05
#===============================================================================
use 5.8.0;
use strict;
use warnings;

Callbackd->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => 1,
);

1;

package Callbackd;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::App);
use Getopt::Long qw(:config auto_version auto_help pass_through);
use PearlPBX::CRUD::Queue;
use Data::Dumper;
use PearlPBX::Config -load;
use PearlPBX::Logger;
use NetSDS::Asterisk::EventListener;
use NetSDS::Asterisk::Manager;

# Queue - The name of the queue.
# MemberName - The name of the queue member.
#  Interface - The queue member's channel technology or location.
# StateInterface - Channel technology or location from which to read device state changes.
# Membership dynamic, realtime, static
# Penalty - The penalty associated with the queue member.
# CallsTaken - The number of calls this queue member has serviced.
# LastCall - The time this member last took a call, expressed in seconds since 00:00, Jan 1, 1970 UTC.
# InCall - Set to 1 if member is in call. Set to 0 after LastCall time is updated.
# Status - The numeric device state status of the queue member.

use constant QueueStatus => [ qw/
AST_DEVICE_UNKNOWN
AST_DEVICE_NOT_INUSE
AST_DEVICE_INUSE
AST_DEVICE_BUSY
AST_DEVICE_INVALID
AST_DEVICE_UNAVAILABLE
AST_DEVICE_RINGING
AST_DEVICE_RINGINUSE
AST_DEVICE_ONHOLD
/];

use constant PauseStatus => [ qw/
NOT_IN_PAUSE
PAUSED
/];


use constant CALL_TIMEOUT => 60*1000;

sub start {
    my $this = shift;
    $this->SUPER::start();
    $SIG{INT}  = sub { $this->{to_finalize} = 1; };
    $SIG{TERM} = sub { $this->{to_finalize} = 1; };
    
    $this->{agentas} = undef; # Just declare 
}

sub _check_queue_status {
    my $this = shift;

    $this->queue_status();
    return unless defined ( $this->{'queue_members'} );

    foreach my $qm ( @{$this->{queue_members}} ) {
        # too verbose
        # $this->log( "info", $qm->{'StateInterface'} . " " . QueueStatus->[$qm->{'Status'}] . " " . PauseStatus->[$qm->{'Paused'}]);
        if ($qm->{'Event'} eq 'QueueMember') {

            my $agent = $qm->{'StateInterface'};
            unless ( defined ( $this->{agentas}->{$agent} ) ) {
                $this->{agentas}->{$agent} = time(); # remember the time when last state changed 
            }

            if ($qm->{'Paused'} == 0) {
                if ($qm->{'Status'} == 1) {
                    my $queue = $qm->{'Queue'};
                    my $service = substr $queue, 8; # Cut "Callback" prefix from QueueName to find the service in the DB
                    my $lastCall = time() - $this->{agentas}->{$agent}; 
                    Infof("[QUEUESTATUS] Found available %s for service %s. Call %d ago", $agent, $service, $lastCall); 
                    next unless $service eq 'SOS'; # DEBUG VERSION
                    next unless $lastCall > 10; # Do not call if $agent available less than 10 seconds 
                    my $dst = $this->_get_today_undone ($service);
                    unless ( defined ( $dst ) ) {
                        Infof("No destination for service %s",$service);
                        next;
                    }
                    $this->_originate_call($dst, $agent, $service);
                    Infof("Calling to %s with connect to %s and service %s", $agent, $dst, $service);
                    return;
                } #end if status == 1
            } #end if
        } #end if
    } #end foreach
    Info("--------> END OF STATUS <----------"); 
}

sub _originate_call {
    my ($this, $dst, $agent, $service) = @_;

    $this->log("info","Calling to $agent with connect to $dst and service $service");
    $this->_set_inprogress($service, $dst);
    $this->mgr->sendcommand (
        Action   => 'Originate',
        ActionID => $dst,
        Channel  => $agent,
        Context  => "IVR2020".$service."Callback",
        Exten    => $dst,
        Priority => '1',
        Timeout  => CALL_TIMEOUT,
        CallerID => $dst,
        Account  => $service,
        Async    => 'true',
    );

    my $reply = 0;
    while ( !$reply ) {
        $reply = $this->mgr->receive_answer();
        $this->log( "info", Dumper $reply);
    }

}

sub queue_status {
    my $self  = shift;

    my $sent = $self->mgr->sendcommand('Action' => 'QueueStatus');
    unless ( defined($sent) ) {
        return undef;
    }
    my $reply = $self->mgr->receive_answer();
    unless ( defined($reply) ) {
        return undef;
    }

    my $status = $reply->{'Response'};
    unless ( defined($status) ) {
        return undef;
    }
    if ( $status ne 'Success' ) {
        die "Response not success\n";
        return undef;
    }

    my @queue_members;

    my @replies;
    while (1) {
        $reply  = $self->mgr->receive_answer();
        my $event = $reply->{'Event'};
        if ( $event =~ /QueueStatusComplete/i ) {
            last;
        }
        if ( $reply->{'Queue'} =~ 'Callback' ) {
            if ( $event =~ /QueueParams/i ) {
                $self->{queue_params} = $reply;
            } elsif ( $event =~ /QueueMember/i ) {
                push @queue_members, $reply;
            }
        }
    }
    $self->{queue_members} = \@queue_members;
    return 1;
}

sub _get_today_undone {
    my $this       = shift;
    my $service    = shift;

    # Find all undone applications for last 1 hour
    my $sth = $this->dbh->prepare(
        "select * from callback_list where created >= now()-'1 hour'::interval and not inprogress and servicename=? order by updated limit 1");
    eval { $sth->execute($service); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    return undef unless ( defined ( $result ) );
    return $result->{'callerid'};
}

sub _set_inprogress {
    my $this = shift;
    my $service = shift;
    my $callerid = shift;

    my $sth = $this->dbh->prepare(
        "update callback_list set inprogress='t' where servicename=? and callerid=?"
    );
    eval { $sth->execute($service, $callerid); };
    if ( $@ ) {
       $this->_exit( $this->dbh->errstr );
    }
    return 1;
}

sub _set_end_progress {
    my $this = shift;
    my $num  = shift;

    eval {
        $this->dbh->do("update callback_list set inprogress='f' where callerid='$num'");
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    };
    return 1;
}

sub _cutoff_channel {
    my $this    = shift;
    my $channel = shift;
    my ( $proto, $a ) = split( '/', $channel );
    my ( $peername, $channel_number ) = split( '-', $a );

    return $peername;
}


sub process {
    my $this = shift;

    my $event = undef;
    $event = $this->el->_getEvent();

    unless ( defined ( $event ) ) {
        Info("EOF from asterisk manager");
        $this->{to_finalize} = 1;
        return;
    }

    if ($event == 0)  {
        sleep(1);
        return;
    }

    unless ( defined ( $event->{'Event'} ) ) {
        Debug("STRANGE EVENT: %s", $event);
        return;
    }

    if ( $event->{'Event'} =~ 'OriginateResponse' ) {
        if ($event->{'Reason'} != 4) {
            $this->_set_end_progress($event->{'ActionID'});
        }
    }

    if ( $event->{'Event'} =~ 'QueueMemberStatus' ) {
        if ( $event->{'Paused'} == 0 ) {
            if ( $event->{'Queue'} =~ 'Callback' ) {
                my $agent = $event->{'StateInterface'};
                Infof("%s %s %s", $agent,  QueueStatus->[$event->{'Status'}], PauseStatus->[$event->{'Paused'}]);
                $this->{agentas}->{$agent} = time();
            }
        }
    }

    unless ( defined ( $this->{'queue_checked'} ) ) {
        $this->_check_queue_status();
        $this->{'queue_checked'} = time;
        return;
    }

    if ( $this->{'queue_checked'} < (time - 10))  {
        $this->_check_queue_status();
        $this->{'queue_checked'} = time;
    }

}
1;
