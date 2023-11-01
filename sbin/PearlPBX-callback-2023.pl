#!/usr/bin/env perl
#===============================================================================
#         FILE:  PearlPBX-callbackd-2023.pl
#        USAGE:  ./PearlPBX-callbackd-2023.pl [ --verbose ]
#  DESCRIPTION:  Simple callback. Look into callback_list, find undone applications and call to user, and redirect it to IVR2020
# REQUIREMENTS:  Scenarios for the short numbers 2023
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      CREATED:  2023-11-01
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

use constant CALL_TIMEOUT => 60*1000;

sub start {
    my $this = shift;
    $this->SUPER::start();
    $SIG{INT}  = sub { $this->{to_finalize} = 1; };
    $SIG{TERM} = sub { $this->{to_finalize} = 1; };

    unless ( defined ( $ARGV[0] ) ) {
        $this->speak(
            "Usage: " . $this->name . ' <service> <context>' . "\n" );
        exit(-1);
    }
    $this->{service} = $ARGV[0];
    unless ( defined ( $ARGV[1]) ) {
        $this->speak(
            "Usage: " . $this->name . ' <service> <context>' . "\n" );
        exit(-1);
    }
    $this->{context} = $ARGV[1];
}

sub _originate_call {
    my ($this, $dst, $service, $context) = @_;

    $this->log("info","Calling to $dst with connect to $context and service $service");
    print("Calling to $dst with connect to $context and service $service\n");
    $this->_set_inprogress($service, $dst);
    $this->mgr->sendcommand (
        Action   => 'Originate',
        ActionID => $dst,
        Channel  => "Local/$dst\@default",
        Context  => $context,
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
        ($reply);
    }

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
        $this->dbh->do("update callback_list set inprogress='f', updated=now() where callerid='$num'");
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    };
    return 1;
}

sub _delete_from_list {
    my $this = shift;
    my $num  = shift;

    eval {
        $this->dbh->do("delete from callback_list where callerid='$num'");
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

    my $event = $this->el->_getEvent();

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
        print Dumper($event);
        if ($event->{'Reason'} != 4) {
            $this->_set_end_progress($event->{'ActionID'});
        }
    }

    my $dst = $this->_get_today_undone ($this->{service});
    unless ( defined ( $dst ) ) {
        return;
    }

    $this->_originate_call($dst, $this->{service}, $this->{context});
}
1;
