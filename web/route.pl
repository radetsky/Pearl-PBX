#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  route.pl
#
#  DESCRIPTION:  PearlPBX route management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  27.08.2012
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Data::Dumper; 
use PearlPBX::Route;

my $pearl = Pearl->new();

my $action = $pearl->{cgi}->param('a');

my $out = ''; 

unless ( defined ( $action ) ) { 
	$pearl->htmlError("Action not found.");
  exit(0);
} 

my $route = PearlPBX::Route->new('/etc/PearlPBX/asterisk-router.conf');
$route->db_connect();
$pearl->htmlHeader;

if ( $action eq 'list-directions-tab') {
	print $route->list_directions_tab;
	exit(0); 
}

$pearl->htmlError("Action not found.");
exit(0);

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

