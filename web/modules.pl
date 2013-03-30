#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  modules.pl
#
#        USAGE:  ./modules.pl 
#
#  DESCRIPTION: Pearl PBX Modules Engine  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Pearl PBX 
#      VERSION:  1.0
#      CREATED:  28.03.2013 
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Data::Dumper; 

my $pearl = Pearl->new();

my $listmodules = $pearl->{cgi}->param('list-modules');
my $execmodule  = $pearl->{cgi}->param('exec-module');

my $out = ''; 

# exec-module have higher priority 
if ( defined ( $execmodule ) ) { 
	my $shortname = $pearl->{cgi}->param('exec-module'); 
	my $modulename = "PearlPBX::Module::".$shortname;
	$pearl->htmlHeader;

	eval "use $modulename;"; 
	if ( $@ ) { 
		$pearl->htmlError("Module not found.");
		exit(0); 
	} 
	my $module = $modulename->new('/etc/PearlPBX/asterisk-router.conf');
	$module->db_connect();

	my $params = $pearl->cgi_params_to_hashref(); 
    $module->run ( $params );
    
	exit(0); 
}

if ( defined ( $listmodules ) ) { 
  	my $rtype = $pearl->{cgi}->param('rtype');
	if ($listmodules == 1) {
		$out .= '<ul class="nav nav-tabs">'; 

		my @list = $pearl->modulesnames($rtype); 
		foreach my $item (@list) { 
			$out .= '<li><a href="javascript:void(0)" onclick="pearlpbx_show_module('."\'#".@$item[0]."\'".')">'.@$item[1] .'</a></li>';
		}
		$out .= '</ul>'; 
	}
	if ($listmodules == 2) {
		$out = $pearl->modulesbodies($rtype);
	}

	$pearl->htmlHeader; 
	print $out; 
  	exit(0);
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

