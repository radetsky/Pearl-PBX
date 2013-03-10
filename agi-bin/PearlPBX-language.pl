#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-language.pl
#
#        USAGE:  ./PearlPBX-language.pl 
#
#  DESCRIPTION:  AGI Get or Set Language to caller
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

Language->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1, 
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;
 
package Language; 

use base 'PearlPBX::IVR'; 

sub process { 
  my $this = shift; 

  unless ( defined( $ARGV[0] ) ) {
    $this->agi->verbose("Usage: " . $this->name . '<get|set> ${CALLERID(num)} <ru|ua|en>', 3);
    exit(-1);
  }
  unless ( defined( $ARGV[1] ) ) {
    $this->agi->verbose("Usage: " . $this->name . '<get|set> ${CALLERID(num)} <ru|ua|en>', 3);
    exit(-1);
  }
  unless ( defined( $ARGV[2] ) ) {
    $this->agi->verbose("Usage: " . $this->name . '<get|set> ${CALLERID(num)} <ru|ua|en>', 3);
    exit(-1);
  }

#-------------  
  if ($ARGV[0] =~ /^get/i ) { 
	my $sql = "select lang_code from ivr.language where msisdn=?"; 
	my $sth = $this->dbh->prepare($sql);
	eval { $sth->execute ( $ARGV[1] ); };
        if ( $@ ) { $this->agi->verbose ( $this->dbh->errstr ); exit(-1); } 
	my $res = $sth->fetchrow_hashref;
	my $lang_code; 
	unless ( $res ) { 
		$lang_code = "none"; 
	} else { 
 		$lang_code = $res->{'lang_code'}; 
	}
  	$this->agi->set_variable("LANGCODE",$lang_code); 
	exit(0);		
  } 

  if ($ARGV[0] =~ /^set/i ) { 
	my $sql = "delete from ivr.language where msisdn=?"; 
	my $sql2 = "insert into ivr.language (msisdn,lang_code) values (?,?);"; 

	my $sth = $this->dbh->prepare($sql);
	my $sth2 = $this->dbh->prepare($sql2); 

	eval { $sth->execute ( $ARGV[1] ); }; 
        if ( $@ ) { $this->agi->verbose ( $this->dbh->errstr ); exit(-1); }
	eval { $sth2->execute ( $ARGV[1],$ARGV[2]); } ; 
	if ( $@ ) { $this->agi->verbose ( $this->dbh->errstr ); exit(-1); }
	$this->agi->set_variable("LANGCODE",$ARGV[2]);
	exit(0);
  }

  $this->agi->verbose("Unsupported operation!",3); 
  exit(0);
}

1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-language.pl

=head1 SYNOPSIS

PearlPBX-language.pl

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

