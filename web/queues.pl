#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  queues.pl
#
#  DESCRIPTION:  PearlPBX Queues management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  31.07.2012
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Data::Dumper; 
use PearlPBX::Queues;

my $pearl = Pearl->new();

my $action = $pearl->{cgi}->param('a');

my $out = ''; 

unless ( defined ( $action ) ) { 
	$pearl->htmlError("Action not found.");
  exit(0);
} 

my $queues = PearlPBX::Queues->new('/etc/PearlPBX/asterisk-router.conf');
$queues->db_connect();
$pearl->htmlHeader;

if ( $action eq 'list') {
	my $b = $pearl->{cgi}->param('b');
	unless ( defined ( $b ) ) { 
	  $pearl->htmlError("Method not found.");
	  exit(0);
	}
	if ($b eq 'li' ) { print $queues->list_as_li;  exit(0); } 
	$pearl->htmlError("Method not found.");
	exit(0); 
}

if ($action eq 'listmembers') { 
	my $b = $pearl->{cgi}->param('b'); 
	unless ( defined ($b)) { 
		$pearl->htmlError("Method not found.");
		exit(0);
	}
	print $queues->listmembersAsJSON($b);
	exit(0);

}

if ( $action eq 'getqueue') { 
	my $b = $pearl->{cgi}->param('name');
	unless ( defined ( $b ) ) {
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	print $queues->getqueue($b);
	exit(0);
}

if ( $action eq 'setqueue') { 
	unless ( defined ( $pearl->{cgi}->param('oldname')) or 
		     defined ( $pearl->{cgi}->param ('name' )) or 
		     defined ( $pearl->{cgi}->param ('strategy' )) or
		     defined ( $pearl->{cgi}->param ('timeout' )) or
		     defined ( $pearl->{cgi}->param ('maxlen' )) 
		) { 
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	if ($pearl->{cgi}->param('oldname') eq '') { 
		print $queues->addqueue ( 
			$pearl->{cgi}->param ('name'),
			$pearl->{cgi}->param ('strategy'),
			$pearl->{cgi}->param ('timeout'),
			$pearl->{cgi}->param ('maxlen')
		);
		exit(0);

	}
	print $queues->setqueue ( 
			$pearl->{cgi}->param('oldname'),
			$pearl->{cgi}->param ('name' ),
			$pearl->{cgi}->param ('strategy' ),
			$pearl->{cgi}->param ('timeout' ),
			$pearl->{cgi}->param ('maxlen' )
		);
	exit(0);
}

if ( $action eq 'addmember') { 
	my $b = $pearl->{cgi}->param('queue');
	unless ( defined ( $b ) ) {
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	my $c = $pearl->{cgi}->param('newmember');
	unless ( defined ( $c ) ) {
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	print $queues->addmember($b,$c);
	exit(0);
}

if ( $action eq 'removemember') { 
	my $b = $pearl->{cgi}->param('queue');
	unless ( defined ( $b ) ) {
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	my $c = $pearl->{cgi}->param('member');
	unless ( defined ( $c ) ) {
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	print $queues->removemember($b,$c);
	exit(0);
}

if ($action eq 'delqueue') { 
	my $b = $pearl->{cgi}->param('queue');
	unless ( defined ( $b ) ) {
		$pearl->htmlError ("Method not found");
		exit(0);
	}
	print $queues->delqueue($b);
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

