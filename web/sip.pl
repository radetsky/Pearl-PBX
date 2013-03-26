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
#     REVISION:  002
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

my $sip = PearlPBX::SIP->new('/etc/PearlPBX/asterisk-router.conf');
$sip->db_connect();
$pearl->htmlHeader;

if ( $action eq 'list') {

	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
	  exit(0);
	}

	if ($b eq 'internal' ) { print $sip->list_internal; } 
	if ($b eq 'external' ) { print $sip->list_external; } 
	if ($b eq 'internal-free') { print $sip->list_internal_free; }
	if ($b eq 'internalAsOption') { print $sip->list_internalAsOption;}
	if ($b eq 'externalAsOption') { print $sip->list_externalAsOption;}
	if ($b eq 'internalAsOptionIdValue') { print $sip->list_internalAsOptionIdValue;}
	if ($b eq 'externalAsOptionIdValue') { print $sip->list_externalAsOptionIdValue;}
	if ($b eq 'internalAsJSON') { print $sip->list_internalAsJSON;}
	if ($b eq 'externalAsJSON') { print $sip->list_externalAsJSON;}

	exit(0); 
}

if ($action eq 'newsecret') { 

	print $sip->newsecret; 
	exit(0);
}
if ($action eq 'adduser') {
	my $params = $pearl->cgi_params_to_hashref();
	print $sip->adduser ( $params );
	exit(0);
}
if ($action eq 'setuser') {
	my $params = $pearl->cgi_params_to_hashref();
	print $sip->setuser ( $params );
	exit(0);
}

if ($action eq 'getuser') { 
	my $id = $pearl->{cgi}->param('id'); 
	unless ( defined ( $id )) { 
		print "ERROR: id is undefined";
		exit(0);
	}
	print $sip->getuser($id);
	exit(0);
}

if ($action eq 'getpeer') { 
	my $id = $pearl->{cgi}->param('id'); 
	unless ( defined ( $id )) { 
		print "ERROR: id is undefuned"; 
		exit(0); 
	}
	print $sip->getpeer($id); 
	exit(0); 
}

if ($action eq 'setpeer') {
	my $params = $pearl->cgi_params_to_hashref();
	print $sip->setpeer ( $params );
	exit(0);
}

if ($action eq 'monitor_get_sip_db') { 
	print $sip->monitor_get_sip_db; 
	exit(0);
}

if ($action eq 'tftp_reload') { 
	print $sip->tftp_reload; 
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

