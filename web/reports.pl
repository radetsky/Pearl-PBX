#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  reports.pl
#
#        USAGE:  ./reports.pl 
#
#  DESCRIPTION: Pearl Reports Engine  
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
use PearlPBX::Report::ExternalNumbers;
use PearlPBX::Report::ListQueues; 

my $pearl = Pearl->new();

my $listreports = $pearl->{cgi}->param('list-reports');
my $execreport = $pearl->{cgi}->param('exec-report');
my $listnumbers = $pearl->{cgi}->param('list-external-numbers');
my $listqueues = $pearl->{cgi}->param('list-queues');

my $out = ''; 

# exec-report have high priority 
if ( defined ( $execreport ) ) { 
	my $reportname = $pearl->{cgi}->param('exec-report'); 
	my $modulename = "PearlPBX::Report::".$reportname;

	eval "use $modulename;"; 
	if ( $@ ) { 
		$pearl->htmlError("Module not found.");
		exit(0); 
	} 
	my $report = $modulename->new('/etc/PearlPBX/asterisk-router.conf');
	$report->db_connect();

	my $params = $pearl->cgi_params_to_hashref(); 

	$pearl->htmlHeader;
  $report->report ( $params );

	exit(0); 
}
if ( defined ( $listreports ) ) { 
  my $rtype = $pearl->{cgi}->param('rtype');
	if ($listreports == 1) {
		$out .= '<ul class="nav nav-tabs">'; 

# Show short list of reports. Just names.
		my @list = $pearl->listreportsnames($rtype); 
		foreach my $item (@list) { 
			$out .= '<li><a href="javascript:void(0)" onclick="pearlpbx_show_report('."\'#".@$item[0]."\'".')">'.@$item[1] .'</a></li>';
		}
		$out .= '</ul>'; 
	}
	if ($listreports == 2) {
		$out = $pearl->reportsbodies($rtype);
	}
	$pearl->htmlHeader; 
	print $out; 
  exit(0);
}

if ( defined ( $listnumbers ) ) { 
	if ($listnumbers == 1 ) {
		my $n = PearlPBX::Report::ExternalNumbers->new("/etc/PearlPBX/asterisk-router.conf");
		$n->db_connect();
		$pearl->htmlHeader;
		$n->report();
		exit(0);
	} 
}
if ( defined ( $listqueues ) ) { 
	if ($listqueues == 1 ) {
		my $n = PearlPBX::Report::ListQueues->new("/etc/PearlPBX/asterisk-router.conf");
		$n->db_connect();
		$pearl->htmlHeader;
		$n->report();
		exit(0);
	} 
}


$pearl->htmlError('No action given.');	
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

