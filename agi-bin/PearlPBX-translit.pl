#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-translit.pl
#
#        USAGE:  ./PearlPBX-translit.pl 
#
#  DESCRIPTION:  AGI Blacklist
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

Translit->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1, 
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;
 
package Translit; 
use base 'PearlPBX::IVR'; 
use NetSDS::Util::Translit qw/trans_cyr_lat/; 

sub process { 
	my $this = shift; 
	unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose("Usage: " . $this->name . ' Some string ', 3);
        exit(-1);
  }

  my $translit = trans_cyr_lat($ARGV[0],'ru'); 
  $this->agi->set_variable ('TRANSLITSTATUS',$translit); 

  exit(0);
}

1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-translit.pl

=head1 SYNOPSIS

PearlPBX-translit.pl

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

