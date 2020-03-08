#!/usr/bin/perl
#===============================================================================
#        USAGE:  qmonitor.pl <queueName> <start/stop>
#  DESCRIPTION:  Queue monitoring tool for PearlPBX
#       AUTHOR:  Alex Radetsky <rad@pearlpbx.com>
#      COMPANY:  PearlPBX
#      CREATED:  2017-07-13
#===============================================================================
#
# QMonitor listen AMI events, asks AMI about queue status
# 0. Update strategy to random or other instead of ringall ( constant STRATEGY )
# 1. Pause agents which do not answer for long time (constant LASTCALL in seconds )
# 2. Pause all unavailable agents
# 3. Listen AMI events to find some agent that do not answer for incoming call for N times
# 4. Pause them when counter of unanswered call >= N times (constant UNANSWERED )

use strict;
use warnings;

# use lib "./lib";
$ENV{LOG_STDERR} = 1;
QMonitor->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => undef,
    has_conf    => 1,
    conf_file   => "/etc/PearlPBX/asterisk-router.conf",
    infinite    => 1,
);

1;

package QMonitor;

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

use constant STRATEGY => 'rrmemory'; # New strategy
use constant LASTCALL => 7200;     # Did not answer for 1 hour ? -> Pause
use constant UNANSWERED => 3;      # Did not answer 5 times ? -> Pause
use constant UNAVAILABLE => 5;     # Status = 5 in QueueStatus means that agent unavailable
use constant REACHABLE => 1;


use constant DEFAULT_SERVICE => 'ExpressT'; 

sub start {
    my $self = shift;
    # Looking for --qname=queueName
    # We will handle SIGKILL, SIGTERM to return status quo

    my $qname; GetOptions  ('qname=s' => \$qname ); $self->{'qname'} = $qname;
    unless ( defined ( $qname ) ) {
          die "Use --qname=%s to set queue name to monitor\n";
    }

    $self->SUPER::start();

    unless ( $self->queue_status( $qname ) ) {
        die "Something wrong with communication with Asterisk Manager\n";
    }

    $self->pause_lean_agents();

    # $self->remember_strategy();
    # Remember that original params saved in $self->{queue_params};

    $self->update_strategy();

    # Goto to process() to listen AMI

    $SIG{INT}  = sub { $self->{to_finalize} = 1; };
    $SIG{TERM} = sub { $self->{to_finalize} = 1; };
}

sub stop {
    my $self = shift;

    Info("Finishing...");

    #restore strategy
    $self->update_strategy($self->{queue_params}->{'Strategy'});
}

sub _service {
    my $self = shift; 
    my $param = shift; 

    
    #  CallbackAutoExpress
    #  CallbackAutoExpress
    #  Callbackavz
    #  CallbackExpressT
    #  Callbackse
    #  CallbackTechnichki
    #  CallbackSOS
    #  Callback247

    my $service = {
        'IVR2020_24NA7' => '247',
        'IVR2020_AutoExpress' => 'AutoExpress',
        'IVR2020_AVZ' => 'avz',
        'IVR2020_ExpressT' => 'ExpressT',
        'IVR2020_SE' => 'se',
        'IVR2020_SOS' => 'SOS',
        'IVR2020_TEHNICHKI' => 'Technichki'
    };

    return $service->{$param} // DEFAULT_SERVICE; 
}


sub queue_status {
    my $self  = shift;
    my $qname = shift;

    my $foundQueue = undef;

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
        # warn Dumper $reply;
        my $event = $reply->{'Event'};
        if ( $event =~ /QueueStatusComplete/i ) {
            last;
        }
        if ( $reply->{'Queue'} eq $qname ) {
            if ( $event =~ /QueueParams/i ) {
            $self->{queue_params} = $reply;
            $foundQueue = 1;
            } elsif ( $event =~ /QueueMember/i ) {
            push @queue_members, $reply;
            }
        }
    }
    $self->{queue_members} = \@queue_members;

    unless ( defined ( $foundQueue ) ) {
        die "Given queue name not found in QueueStatus response\n";
    }
    return 1;
}

sub pause_lean_agents {
    my $self = shift;

    Info("Pause lean agents...");

    my $current_time = time;
    foreach my $member ( @{$self->{queue_members}}) {
        if ( ( $member->{'LastCall'} > 0 ) && ( $member->{'LastCall'} < ( $current_time - LASTCALL ) ) ) {
            Infof("Pause lean member %s", $member->{'StateInterface'} );
            $self->pause_member($member->{'StateInterface'}, 'true');
        }
        if ($member->{'Status'} == UNAVAILABLE ) {
            Infof("Pause unavailable member %s", $member->{'StateInterface'});
            $self->pause_member($member->{'StateInterface'}, 'true');
        }
    }
}

sub pause_member {
    my ($self, $member, $status) = @_;

    Infof("Queue pause member %s to status %s", $member, $status);

    my $sent = $self->mgr->sendcommand (
        'Action'    => 'QueuePause',
        'Interface' => $member,
        'Paused'    => $status,
        'Queue'     => $self->{qname},
    );

    unless ( defined($sent) ) {
        return undef;
    }
    my $reply = $self->mgr->receive_answer();
    unless ( defined($reply) ) {
        return undef;
    }
    my $response = $reply->{'Response'};
    unless ( defined ( $response ) ) {
        return undef;
    }
    if ( $response ne 'Success' ) {
        Errf("Response not success: %s", Dumper $reply);
        return undef;
    }
}

sub update_strategy {
    my $self = shift;
    my $strategy = shift // STRATEGY;

    Infof("Update strategy to %s", $strategy);
    my $sql = "update queues set strategy=? where name=?";
    my $sth = $self->dbh->prepare($sql);
    $sth->execute($strategy, $self->{qname});
    $self->queue_reload_parameters();
}

sub queue_reload_parameters {
    my $self = shift;
    Infof("Reload parameters for %s", $self->{qname});
    my $command = 'queue reload parameters '. $self->{qname};
    # warn $command;
    my $sent = $self->mgr->sendcommand (
        'Action'  => "Command",
        'Command' => $command,
    );

    while (1) {
        my $reply  = $self->mgr->receive_answer();
        unless ( defined ( $reply ) ) {
            last;
        }
        if ( $reply == 0 ) {
            last;
        }
        Infof("Got response: %s", $reply);
    }

}

sub incrementFailCounter {
    my $self = shift;
    my $interface = shift;

    if ( defined ( $self->{failcounters}->{$interface})) {
        $self->{failcounters}->{$interface} = $self->{failcounters}->{$interface} + 1;
    } else {
        $self->{failcounters}->{$interface} = 1;
    }

    Infof("FailCounter for %s set to %d", $interface, $self->{failcounters}->{$interface});

    if ($self->{failcounters}->{$interface} > UNANSWERED ) {
        $self->pause_member($interface, 'true');
        $self->{failcounters}->{$interface} = 0;
    }
}

sub lookup_in_addressbook {
    my $self     = shift; 
    my $callerid = shift; 

    my $sth = $self->dbh->prepare("select count(msisdn) as c from ivr.addressbook where msisdn=?");
    eval {
        $sth->execute($callerid);
    };
    if ( $@ ) {
        return undef;
    }

    my $result = $sth->fetchrow_hashref();
    if ( ! defined ( $result->{'c'} ) ) {
        return undef;
    }
    if ( $result->{'c'} > 0 ) {
        Infof("%s exists in addressbook", $callerid); 
        return 1;
    }
    return undef;
}

sub add_to_callback {
    my $self = shift;
    my $event = shift;
    
    my $context = $event->{'Context'}; 
    my $servicename = $self->_service($context); 
    my $callerid = $event->{'CallerIDNum'}; 

    return if ( $self->lookup_in_addressbook($callerid) ); 

    Infof("Add to callback %s context %s service %s hold %s pos %s", $event->{'CallerIDNum'}, 
        $context, $servicename, $event->{'HoldTime'}, $event->{'Position'});
    my $sth = $self->dbh->prepare("insert into public.callback_list (callerid, servicename) values(?,?)");
    eval { my $rv = $sth->execute($event->{'CallerIDNum'}, $servicename ); };
    if ($@) {
        Errf( "Can't add to callback_list: %s", $self->dbh->errstr );
    }

}

sub process {
    my $self  = shift;
    my $event = undef;

    $event = $self->el->_getEvent();
    unless ( defined ( $event ) ) {
        Info("EOF from asterisk manager");
        $self->{to_finalize} = 1;
    }

    if ($event == 0)  {
        sleep(1);
        return;
    }

    unless ( defined ( $event->{'Event'} ) ) {
        Debug("STRANGE EVENT: %s", $event);
        return;
    }

    # Checking AgentRingNoAnswer
    if ( $event->{'Event'} eq 'AgentRingNoAnswer') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            my $interface = $event->{'Interface'};
            Infof("Agent %s did not answer to %s %s", $interface, $event->{'Channel'}, $event->{'CallerIDNum'});
            $self->incrementFailCounter($interface);
        }
    } elsif ( $event->{'Event'} eq 'AgentCalled') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            Infof("Agent called %s", $event->{'Interface'});
        }
    } elsif ( $event->{'Event'} eq 'QueueMemberStatus') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            my $interface = $event->{'Interface'};
            my $state = $event->{'Status'};
            if ( $state == UNAVAILABLE ) {
                Infof("Agent UNREACHABLE %s", $interface);
            } elsif ( $state == REACHABLE ) {
                # Infof("Agent AVAILABLE %s", $interface);
            }
        }
    } elsif ( $event->{'Event'} eq 'QueueMemberPause') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            my $interface = $event->{'Interface'};
            my $paused = $event->{'Paused'} == 0 ? 'Unpaused' : 'Paused';
            Infof("Agent %s %s", $interface, $paused );
        }
    } elsif ( $event->{'Event'} eq 'QueueCallerLeave') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            # Infof("We lost caller %s", $event->{'CallerIDNum'});
        }
    } elsif ( $event->{'Event'} eq 'QueueCallerAbandon' ) {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            Infof("We lost caller %s", $event->{'CallerIDNum'});
            # Here: add to callback queue
            $self->add_to_callback($event)
        }
    } elsif ( $event->{'Event'} eq 'QueueCallerJoin') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            Infof("Enter %s", $event->{'CallerIDNum'});
        }
    } elsif ( $event->{'Event'} eq 'AgentConnect') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            my $interface = $event->{'Interface'};
            Infof("Agent %s connected to %s",$interface, $event->{'CallerIDNum'});
            $self->{failcounters}->{$interface} = 0;
        }
    } elsif ( $event->{'Event'} eq 'AgentComplete') {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            Infof("Agent %s complete with %s",$event->{'Interface'}, $event->{'CallerIDNum'});
        }
    } elsif ( defined ( $event->{'Queue'} ) ) {
        if ( $event->{'Queue'} eq $self->{qname} ) {
            # warn Dumper $event->{'Event'};
        }
    }
}

