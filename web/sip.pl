#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  sip.pl
#
#  DESCRIPTION:  PearlPBX SIP management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  23.06.201
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Data::Dumper; 
use PearlPBX::SIP;

my $pearl = Pearl->new();

my $action = $pearl->{cgi}->param('a');

my $out = ''; 

unless ( defined ( $action ) ) { 
	$pearl->htmlError("Action not found.");
  exit(0);
} 

if ( $action eq 'list') {

	my $sip = PearlPBX::SIP->new('/etc/PearlPBX/asterisk-router.conf');
	$sip->db_connect();
	$pearl->htmlHeader;

	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
	  exit(0);
	}

	if ($b eq 'internal' ) { print $sip->list_internal; } 
	if ($b eq 'external' ) { print $sip->list_external; } 
	if ($b eq 'internal-free') { print $sip->list_internal_free; }

	exit(0); 
}



1;
#===============================================================================

__END__

=head1 NAME

reports.pl

=head1 SYNOPSIS

reports.pl

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

