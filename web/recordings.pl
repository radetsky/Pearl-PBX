#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  recordings.pl
#
#        USAGE:  ./recordings.pl 
#
#  DESCRIPTION: Pearl PBX Recordings  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  31.05.2012 10:18:09 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Data::Dumper; 
use PearlPBX::Report::Recordings; 

my $pearl = Pearl->new();

my $listrecordings = $pearl->{cgi}->param('list-recordings');
my $cdr_start = $pearl->{cgi}->param('start'); 
my $cdr_src = $pearl->{cgi}->param('src'); 
my $cdr_dst = $pearl->{cgi}->param('dst');
my $uniqueid = $pearl->{cgi}->param('uniqueid'); 

unless ( defined ( $listrecordings ) 
	or defined ( $cdr_start ) 
	or defined ( $cdr_src ) 
	or defined ( $cdr_dst ) ) { 
		$pearl->htmlError ("Invalid parameters!");
	  exit(0);
  }

my $out = ''; 

my $params = $pearl->cgi_params_to_hashref();

my $report = PearlPBX::Report::Recordings->new('/etc/PearlPBX/asterisk-router.conf');
$report->db_connect();
$pearl->htmlHeader;
$report->report ( $params );

exit(0); 

1;
#===============================================================================

__END__

=head1 NAME

recordings.pl

=head1 SYNOPSIS

recordings.pl

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

