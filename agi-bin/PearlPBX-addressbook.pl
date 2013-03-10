#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-addressbook.pl
#
#        USAGE:  ./PearlPBX-addressbook.pl
#
#  DESCRIPTION:  AGI addressbook
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

addressbook->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package addressbook;

use base 'PearlPBX::IVR';

sub process {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose( "Usage: " . $this->name . ' ${CALLERID(num)}', 3 );
        exit(-1);
    }

    my $sql = "select displayname from ivr.addressbook where msisdn=?";
    my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute( $ARGV[0] ); };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr );
        exit(-1);
    }

    my $res         = $sth->fetchrow_hashref;
    my $displayname = $res->{'displayname'};

    $this->agi->set_variable( 'DISPLAYNAME', '' );
    if ( $displayname ) {
        $this->agi->set_variable( 'DISPLAYNAME', $displayname );
    }

    exit(0);
}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-addressbook.pl

=head1 SYNOPSIS

PearlPBX-addressbook.pl

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

