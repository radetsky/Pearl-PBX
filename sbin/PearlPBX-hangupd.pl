#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-hangupd.pl
#
#        USAGE:  ./NetSDS-hangupd.pl
#
#  DESCRIPTION:  Hangup daemon. Listens AMI for hangup events and clears the integration.ulines table.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  12/19/11 11:24:06 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

NetSDSHangupD->run(
    daemon      => 1,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef
);

1;

package NetSDSHangupD;

use 5.8.0;
use strict;
use warnings;
use DBI;

use base qw(NetSDS::App);
use NetSDS::Asterisk::EventListener;
use NetSDS::Asterisk::Manager;
use Data::Dumper;
use LWP::UserAgent;

our @expire_list = ();

sub start {
    my $this = shift;

    $SIG{TERM} = sub {
        exit(-1);
    };
    $SIG{INT} = sub {
        exit(-1);
    };

    $this->mk_accessors('el');
    $this->mk_accessors('dbh');

    $this->_db_connect();

    $this->{'count'} = 0;

    $this->_el_connect();

}

sub _db_connect {
    my $this = shift;

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->speak("Can't find \"db main->dsn\" in configuration.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->speak("Can't find \"db main->login\" in configuraion.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->speak("Can't find \"db main->password\" in configuraion.");
        exit(-1);
    }

    my $dsn    = $this->conf->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->conf->{'db'}->{'main'}->{'login'};
    my $passwd = $this->conf->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->dbh or !$this->dbh->ping ) {
        $this->dbh(
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }

    return 1;
}

sub _el_connect {
    my $this = shift;

    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->speak("Can't file el->host in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->speak("Can't file el->port in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->speak("Can't file el->username in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->speak("Can't file el->secret in configuration.");
        exit(-1);
    }

    my $el_host     = $this->conf->{'el'}->{'host'};
    my $el_port     = $this->conf->{'el'}->{'port'};
    my $el_username = $this->conf->{'el'}->{'username'};
    my $el_secret   = $this->conf->{'el'}->{'secret'};

    my $event_listener = NetSDS::Asterisk::EventListener->new(
        host     => $el_host,
        port     => $el_port,
        username => $el_username,
        secret   => $el_secret
    );

    $event_listener->_connect();

    $this->el($event_listener);
}

sub _recording_set_finished {
    my $this     = shift;
    my $uniqueid = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare("update integration.recordings set finished=true where cdr_uniqueid=?");

    eval { my $rv = $sth->execute($uniqueid); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
    $this->speak("Set mark finished to $uniqueid");
    return 1;

}

sub _begin {
    my $this = shift;

    eval { $this->dbh->begin_work; };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->log( "error", $errstr );
    exit(-1);
}


sub process {
    my $this = shift;

    my $event   = undef;

    while (1) {
        $event = $this->el->_getEvent();
        unless ($event) {
            # $this->log("info","No event from AMI. Sleeping.");
            sleep(1);
            next;
        }

        unless ( defined ( $event->{'Event'} ) ) {
            warn Dumper ( $event );
            next;
        }

# Event: Hangup
# Privilege: call,all
# Channel: SIP/211-00008af1
# ChannelState: 6
# ChannelStateDesc: Up
# CallerIDNum: 211
# CallerIDName: Оператор 11
# ConnectedLineNum: <unknown>
# ConnectedLineName: <unknown>
# Language: ru
# AccountCode:
# Context: default
# Exten: 0972076323
# Priority: 3
# Uniqueid: 1482346630.65506
# Linkedid: 1482346630.65506
# Cause: 17
# Cause-txt: User busy

        if ( $event->{'Event'} eq 'Hangup' ) {
            #warn Dumper $event; 
            my $channel = $event->{'Channel'};
            my $uniqueid = $event->{'Uniqueid'}; 
            $this->log( "info", "Got hangup for $channel with $uniqueid" );
            $this->_recording_set_finished($uniqueid)
        }
    }

}

#===============================================================================

__END__

=head1 NAME

NetSDS-hangupd.pl

=head1 SYNOPSIS

NetSDS-hangupd.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

