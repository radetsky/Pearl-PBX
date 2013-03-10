#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-poperator.pl
#
#        USAGE:  ./PearlPBX-poperator.pl
#
#  DESCRIPTION:  AGI poperator
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

Poperator->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Poperator;

use base 'PearlPBX::IVR';
use Data::Dumper; 

sub process {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <get|set> ${CALLERID(num)} [SIP/operator]',
            3
        );
        exit(-1);
    }
    unless ( defined( $ARGV[1] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <get|set> ${CALLERID(num)} [SIP/operator]',
            3
        );
        exit(-1);
    }
    unless ( defined( $ARGV[2] ) ) {
        if ( $ARGV[0] =~ /^set$/i ) {
            $this->agi->verbose(
                "Usage: "
                  . $this->name
                  . ' <get|set> ${CALLERID(num)} [SIP/operator]',
                3
            );
            exit(-1);
        }
    }

    if ( $ARGV[0] =~ /^get$/i ) { 
	my $sql = "select id,operator from ivr.personal_operator where msisdn=? order by priority,calldate desc limit 5";
    	my $sth = $this->dbh->prepare($sql);
    	eval { $sth->execute( $ARGV[1] ); };
    	if ($@) { $this->agi->verbose( $this->dbh->errstr );exit(-1); } 
	my $res = $sth->fetchall_hashref('id');
	my $count = keys %{$res}; 
	unless ( $count )  { 
		$this->agi->set_variable("POPERATOR",""); 
		exit(0);
	}
	#warn Dumper ($res); 
	my $poperator = ""; 
	foreach my $id ( keys %{$res} ) { 
		my $operator = $res->{$id}->{'operator'};
		$poperator .= $operator . ",";
	}
	$poperator =~ s/,$//s; 
	$this->agi->set_variable("POPERATOR",$poperator); 
    }
    
    if ( $ARGV[0] =~ /^set$/i ) { 
	my $sql = "insert into ivr.personal_operator (msisdn, operator) values ( ? , ? )"; 
	my $sth = $this->dbh->prepare($sql);
	eval { $sth->execute( $ARGV[1], $ARGV[2] ); };
	if ($@) { $this->agi->verbose( $this->dbh->errstr );exit(-1); }
	$this->agi->set_variable("POPERATOR",$ARGV[2]);		    
    }
    exit(0);
}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-poperator.pl

=head1 SYNOPSIS

PearlPBX-poperator.pl

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

