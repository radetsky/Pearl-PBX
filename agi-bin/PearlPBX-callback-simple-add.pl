#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  PearlPBX-callback-add.pl
#        USAGE:  ./PearlPBX-callback-add.pl
#  DESCRIPTION:  AGI adds application to callback from Call Center.
#      OPTIONS:  ${CALLERID}, ServiceName
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  3.0
#      CREATED:  29.12.2014
#     MODIFIED:  08.10.2018
#     MODIFIED:  01.11.2023 For shorts number
#===============================================================================


use 5.8.0;
use strict;
use warnings;

$| = 1;

Cb->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Cb;

use base 'PearlPBX::IVR';
use Data::Dumper;
use NetSDS::Util::String;

sub _add_callerid {
    my ($this, $callerid, $service) = @_;
    $this->agi->verbose("Adding new call for $callerid for service $service", 3 );
    my $sql = "insert into callback_simple ( callerid, servicename ) values ( ?,? )";
    my $sth = $this->dbh->prepare($sql);
    eval {
        $sth->execute ($callerid, $service );
    };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr, 3 );
        exit(-1);
    }
    $this->agi->verbose("inserted to callback simple: $callerid", 3);
    return 1;
}

sub process {
    my $this = shift;
    my $callerid = $ARGV[0];
    my $service  = $ARGV[1];

    unless ( defined ( $callerid ) ) {
        $this->agi->verbose("CallerID is not defined. Exiting.", 3);
        exit(-1);
    }
    unless ( defined ( $service ) ) {
        $this->agi->verbose("Service is not defined. Exiting.", 3);
        exit(-1);
    }
    $this->_add_callerid($callerid, $service);
    exit(0);
}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-callback-add.pl

=head1 SYNOPSIS

PearlPBX-callback-add.pl

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

