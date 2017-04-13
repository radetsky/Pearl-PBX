#!/usr/bin/env perl
#===============================================================================
#         FILE:  PearlPBX-hangupd.pl
#
#  DESCRIPTION:  Hangup daemon. Listens AMI for hangup events.
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  2.0
#      CREATED:  12/19/11 11:24:06 EET
#     REVISION:  CLONED from NetSDS-Hangupd in Dec 2016.
#     LAST MOD:  2017-02-05
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

use base qw(PearlPBX::App);
use Data::Dumper;
use LWP::UserAgent;
use PearlPBX::Logger;

our @expire_list = ();

sub start {
    my $this = shift;

    $this->SUPER::start();
    $this->{'count'} = 0;

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
    Info("Set mark finished to $uniqueid");
    return 1;

}

sub process {
    my $this = shift;
    my $event= undef;

    while (1) {
        $event = $this->el->_getEvent();
        unless ( defined ( $event ) ) {
            $this->_exit("EOF from manager");
        }
        if ($event == 0 ) {
            sleep(1);
            next;
        }

        unless ( defined ( $event->{'Event'} ) ) {
            Debug("STRANGE EVENT: %s", $event);
            next;
        }

        if ( $event->{'Event'} eq 'Hangup' ) {
            my $channel = $event->{'Channel'};
            my $uniqueid = $event->{'Uniqueid'};
            Info("HangUp for $channel with $uniqueid");
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

