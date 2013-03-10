#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-whitelist.pl
#
#        USAGE:  ./PearlPBX-whitelist.pl 
#
#  DESCRIPTION:  AGI Whitelist
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

Whitelist->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1, 
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;
 
package Whitelist; 

use base 'PearlPBX::IVR'; 


sub process { 
	my $this = shift; 

	unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose("Usage: " . $this->name . ' ${CALLERID(num)}', 3);
        exit(-1);
  }

  my $sql = "select count(*) as whitelisted from public.whitelist where number=?"; 
  my $sth = $this->dbh->prepare($sql);
  eval { $sth->execute ( $ARGV[0] ); }; 
  if ( $@ ) { 
    $this->agi->verbose ( $this->dbh->errstr ); 
    exit(-1);
  }
	
  my $res = $sth->fetchrow_hashref; 
  my $whitelisted = $res->{'whitelisted'}; 
	
  $this->agi->set_variable ('WHITELISTED','0'); 
  if ( $whitelisted > 0 ) { 
	$this->agi->set_variable ('WHITELISTED',$whitelisted);
	$this->agi->exec ("Set(QUEUE_PRIO=10)");  
  }

  exit(0);
}

1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-whitelist.pl

=head1 SYNOPSIS

PearlPBX-whitelist.pl

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

