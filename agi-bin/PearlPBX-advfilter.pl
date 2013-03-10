#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-advfilter.pl
#
#        USAGE:  ./PearlPBX-advfilter.pl
#
#  DESCRIPTION:  AGI advfilter
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  07.03.2013 09:51:52 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

advfilter->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package advfilter;

use base 'PearlPBX::IVR';

sub process {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose( "Usage: " . $this->name . ' ${CALLERID(num)}', 3 );
        exit(-1);
    }

    my $sql = "select playback from ivr.advfilter where msisdn=? and now() between since and till order by id desc limit 1";
    my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute( $ARGV[0] ); };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr );
        exit(-1);
    }

    my $res         = $sth->fetchrow_hashref;
    my $playback = $res->{'playback'};

    $this->agi->set_variable( 'ADVFILTER', '' );
    if ( $playback ) {
        $this->agi->set_variable( 'ADVFILTER', $playback );
    }

    exit(0);
}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-advfilter.pl

=head1 SYNOPSIS

PearlPBX-advfilter.pl

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

