#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-calendar.pl
#
#        USAGE:  ./PearlPBX-calendar.pl 
#
#  DESCRIPTION:  AGI Calendar 
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

Calendar->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1, 
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;
 
package Calendar; 

use base 'PearlPBX::IVR'; 


sub process { 
  my $this = shift; 

  unless ( defined ( $ARGV[0] ) ) { 
	$this->agi->verbose("Usage: ".$this->{name}." <queuename> ", 3); 
	exit(-1);
  }

  my $sql = "select need_work_group from cal.need_work_group(?);"; 
  my $sth = $this->dbh->prepare($sql);
  eval { $sth->execute ( $ARGV[0] ); }; 
  if ( $@ ) { 
    $this->agi->verbose ( $this->dbh->errstr ); 
    exit(-1);
  }
  my $res = $sth->fetchrow_hashref; 
  my $workmode = $res->{'need_work_group'}; 
  
  $this->agi->set_variable ('WORKMODE','0'); 
  if ( ( $workmode > 0 ) or ( $workmode eq 't') )  { 
	$this->agi->set_variable ('WORKMODE',1); 
  }

  exit(0);
}

1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-calendar.pl

=head1 SYNOPSIS

PearlPBX-calendar.pl

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

