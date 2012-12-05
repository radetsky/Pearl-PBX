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
if ( $action eq 'list') { 
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
	  exit(0);
	}

	if ( $b eq 'tgrpsAsOption') { print $route->list_tgrpsAsOption; }
	if ( $b eq 'contextsAsOption') { print $route->list_contextsAsOption; }
	exit(0);

}

if ( $action eq 'list-directions-tab') {
	print $route->list_directions_tab;
	exit(0); 
}

if ( $action eq 'getdirection' ) { 
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $route->getdirectionAsJSON($b);
	exit(0);
}
if ( $action eq 'getrouting' ) { 
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $route->getroutingAsJSON($b);
	exit(0);
}

if ( $action eq 'setdirection' ) { 
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	my $c = $pearl->{cgi}->param('c');
	unless ( defined ( $c ) ) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $route->setdirection($b,$c);
	exit(0);
}
if ( $action eq 'removedirection' ) { 
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $route->removedirection($b);
	exit(0);
}

if ($action eq 'addprefix') { 
	my $b = $pearl->{cgi}->param('b');
	my $c = $pearl->{cgi}->param('c'); 
	my $d = $pearl->{cgi}->param('d');

	unless ( defined ( $b )) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	unless ( defined ( $c )) { 
		$pearl->htmlError("Method not found."); 
		exit(0);
	} 
	unless ( defined ( $d )) { 
		$pearl->htmlError("Method not found."); 
		exit(0);	
	}
	print $route->addprefix($b,$c,$d);
	exit(0);
}
if ($action eq 'removeprefix') {
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b )) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $route->removeprefix ($b); 
	exit(0);
}
if ($action eq 'adddirection') { 
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b ) ) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $route->adddirection($b);
	exit(0);
}
if ($action eq 'removeroute') {
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b ) ) { 
		$pearl->htmlError ("Method not found."); 
		exit(0);
	}
	print $route->removeroute($b); 
	exit(0);
}
if ($action eq 'addrouting') { 
	my $dlist_id = $pearl->{cgi}->param('dlist_id'); 
	my $route_step = $pearl->{cgi}->param('route_step'); 
	my $route_type = $pearl->{cgi}->param('route_type'); 
	my $route_dest = $pearl->{cgi}->param('route_dest'); 
	my $route_src = $pearl->{cgi}->param('route_src'); 

	unless ( defined ( $dlist_id )) { print "ERROR: dlist_id is not defined."; exit(0); }
	unless ( defined ( $route_step ) ) { print "ERROR: route_step is not defined. "; exit (0); }
	unless ( defined ( $route_type ) ) { print "ERROR: route_type is not defined. "; exit (0); }
	unless ( defined ( $route_dest ) ) { print "ERROR: route_dest is not defined. "; exit(0); }
	unless ( defined ( $route_src ) ) { print "ERROR: route_src is not defined. "; exit(0); }

	print $route->addrouting($dlist_id, $route_step, $route_type, $route_dest, $route_src); 
	exit (0); 
}
if ($action eq 'checkroute') {
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b )) { $pearl->htmlError("ERROR: channel is not defined. "); exit(0); }
	my $c = $pearl->{cgi}->param('c'); 
	unless ( defined ( $c )) { $pearl->htmlError("ERROR: destination is not defined. "); exit(0); }
	print $route->checkroute($b, $c); 
	exit(0); 
}
if ($action eq 'loadpermissions') { 
	print $route->loadpermissions();
	exit(0);
}

if ($action eq 'loadpermissionsJSON') {
	print $route->loadpermissionsJSON();
	exit(0);
}

if ($action eq 'savepermissions') { 
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b )) { 
		$pearl->htmlError("ERROR: permissions is not defined."); 
		exit(0); 
	}
	print $route->savepermissions($b); 
	exit(0); 
}
if ( $action eq 'list-trunkgroups-tab') {
	print $route->list_trunkgroups_tab;
	exit(0); 
}
if ( $action eq 'gettrunkgroup-items') { 
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b )) { 
		$pearl->htmlError ("ERROR: tgrp_id is not defined.");
		exit(0);
	}
	print $route->gettrunkgroup_items($b);
	exit(0);
}

if ( $action eq 'newtrunkgroup' ) {
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b )) { 
		$pearl->htmlError("ERROR: tgrp_name is not defuned.");
		exit(0);
	}
	print $route->newtrunkgroup($b);
	exit(0);
}

if ( $action eq 'updatetrunkgroup') { 
	my $b = $pearl->{cgi}->param('b');
	my $c = $pearl->{cgi}->param('c'); 
	unless ( defined ( $b )) {
		$pearl->htmlError("ERROR: tgrp_id is not defined.");
		exit(0);
	}
	unless ( defined ( $c )) { 
		$pearl->htmlError("ERROR: tgrp_name is not defined.");
		exit(0);
	}
	print $route->updatetrunkgroup($b,$c); 
	exit(0);
}

if ( $action eq 'tgrp_addmember' ) { 
	my $b = $pearl->{cgi}->param('newmember'); 
	unless ( defined ( $b )) { 
		$pearl->htmlError("ERROR: newmember is not defined."); 
		exit(0);
	}
	my $c = $pearl->{cgi}->param('tgrp_id'); 
	unless ( defined ( $c )) { 
		$pearl->htmlError("ERROR: tgrp_id is not defined."); 
		exit(0); 
	}
	print $route->tgrp_addmember($b,$c);
	exit(0);
}

if ($action eq 'tgrp_removemember') {
	my $b = $pearl->{cgi}->param('member');
	unless ( defined ( $b )) {
		$pearl->htmlError("ERROR: tgrp_item_id is not defined."); 
		exit(0);
	}
	print $route->tgrp_removemember ($b); 
	exit(0);
}

if ($action eq 'removetrunkgroup') { 
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b )) { 
		$pearl->htmlError("ERROR: tgrp_id is not defined."); 
		exit(0);
	}
	print $route->removetrunkgroup($b);
	exit(0);
}
if ($action eq 'loadcallerid') { 
	print $route->loadcallerid; 
	exit(0);
}



if ($action eq 'setcallerid_remove_id') { 
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ( $b )) { 
		$pearl->htmlError("ERROR: set_callerid_id is not defined."); 
		exit(0);
	}
	print $route->setcallerid_remove_id($b);
	exit(0);
}

if ($action eq 'list-directions-options') { 
	print $route->list_directions_options; 
	exit(0); 
}

if ($action eq 'setcallerid_add') { 
	my $direction_id = $pearl->{cgi}->param('direction_id'); 
	my $sip_id = $pearl->{cgi}->param('sip_id'); 
	my $callerid = $pearl->{cgi}->param('callerid'); 

	unless ( defined ( $direction_id )) { print "ERROR: direction_id not defined."; exit(0); }
	unless ( defined ( $sip_id )) { print "ERROR: sip_id not defined."; exit(0); }
	unless ( defined ( $callerid )) { print "ERROR: callerid not defined."; exit(0); }

	print $route->setcallerid_add($direction_id, $sip_id, $callerid); 
	exit(0); 
	
}

if ($action eq 'load_convert_exten') { 
	print $route->load_convert_exten; 
	exit(0);
}

if ($action eq 'add_convert_exten') { 
	my $exten = $pearl->{cgi}->param('exten'); 
	my $operation = $pearl->{cgi}->param('operation');
	my $param = $pearl->{cgi}->param('param'); 
	my $step = $pearl->{cgi}->param('step'); 

	unless ( defined ( $exten )) { print "ERROR: exten not defined. "; exit(0); }
	unless ( defined ( $operation )) { print "ERROR: operation not defined. "; exit(0); }
	unless ( defined ( $param )) { print "ERROR: param not defined. "; exit (0); }
	unless ( defined ( $step )) { print "ERROR: step not defined. "; exit(0); }

	print $route->add_convert_exten ($exten, $operation, $param, $step); 
	exit(0); 
}

if ($action eq 'remove_convert_exten') { 
	my $id = $pearl->{cgi}->param('id'); 

	unless ( defined ( $id )) { print "ERROR: id not defined."; exit (0); }
	print $route->remove_convert_exten ( $id ); 
	exit(0); 
}

if ($action eq 'get_monitor_credentials') { 
	print $route->get_monitor_credentials; 
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

