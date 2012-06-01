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

my $pearl = Pearl->new(); 
my $listreports = $pearl->{cgi}->param('list-reports');
my $execreport = $pearl->{cgi}->param('exec-report'); 

# exec-report have high priority 
if ( defined ( $execreport ) ) { 
	my $reportname = $pearl->{cgi}->param('exec-report'); 
	my $modulename = "PearlPBX::Report::".$reportname; 

	eval { use $modulename; }; 



}
unless ( defined ( $listreports ) ) { 
		$pearl->htmlError('No action given.');	
		exit(0);
}

my $out = ''; 

if ($listreports == 1) {
	$out .= '<ul class="nav nav-tabs">'; 

# Show short list of reports. Just names.
	my @list = $pearl->listreportsnames(); 
	foreach my $item (@list) { 
		$out .= '<li><a href="javascript:void(0)" onclick="pearlpbx_show_report('."\'#".@$item[0]."\'".')">'.@$item[1] .'</a></li>';
	}

	$out .= '</ul>'; 
}

if ($listreports == 2) {
	$out = $pearl->reportsbodies();
}

$pearl->htmlHeader; 
print $out; 
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

