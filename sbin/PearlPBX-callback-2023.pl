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

# create table callback_simple (
#  id bigserial primary key,
#  callerid varchar(16) unique,
#  servicename varchar(32) not null,
#  after timestamp with time zone default now(),
#  created timestamp with time zone default now()
# );

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
    $this->{calltime} = {}; # Hash of calltime for each callerid
}

sub _get_today_undone {
    my $this       = shift;
    my $service    = shift;

    # Find all undone applications for last 1 hour
    my $sth = $this->dbh->prepare(
        "select * from callback_simple where after < now() and servicename=? order by id limit 1");
    eval { $sth->execute($service); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    return undef unless ( defined ( $result ) );
    return $result->{'callerid'};
}

sub _delete_from_list {
    my $this = shift;
    my $num  = shift;

    Info("Deleting from list $num");
    eval {
        $this->dbh->do("delete from callback_simple where callerid='$num'");
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    };
    return 1;
}

sub _originate_call {
    my ($this, $dst, $service, $context) = @_;

    $this->log("info","Calling to $dst with connect to $context and service $service");
    $this->_delete_from_list($dst);
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
        Info($reply);
    }
}

sub _set_calltime {
    my ($this, $num, $calltime, $service) = @_;

    Info("Setting calltime for $num to $calltime");
    print("Setting calltime for $num to $calltime\n");
    $this->{calltime}{$num} = $calltime;
    eval {
        $this->dbh->do("insert into callback_simple (callerid, servicename, after) values ('$num', '$service', now() + '$calltime seconds'::interval)");
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    };

}

sub _get_calltime {
    my ($this, $num) = @_;

    unless ( defined ($this->{calltime}{$num}) ) {
        return 0;
    }
    return $this->{calltime}{$num};
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
        if ($event->{'Reason'} == 4) {
            undef $this->{calltime}{$event->{'ActionID'}};
        } else {
            my $calltime = $this->_get_calltime($event->{'ActionID'});
            if ($calltime >= 0 && $calltime < 180) {
                $this->_set_calltime($event->{'ActionID'}, 180, $this->{service});
            } elsif ($calltime >= 180 && $calltime < 300) {
                $this->_set_calltime($event->{'ActionID'}, 300, $this->{service});
            } else {
                $this->_delete_from_list($event->{'ActionID'});
            }
        }
    }
    my $dst = $this->_get_today_undone ($this->{service});
    unless ( defined ( $dst ) ) {
        return;
    }
    $this->_originate_call($dst, $this->{service}, $this->{context});
}
1;
