#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-addmissed.pl
#
#        USAGE:  ./PearlPBX-addmissed.pl
#
#  DESCRIPTION:  AGI adds missed call to given group in QueueLog. 
#
#      OPTIONS:  ${CALLERID}, ${GROUP} 
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  13.01.2014
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

Missed->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Missed;

use base 'PearlPBX::IVR';
use Data::Dumper;
use NetSDS::Util::String;  

sub process {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' ${CALLERID(num)} ${GROUP/QUEUE} ${UNIQUEID}',
            3
        );
        exit(-1);
    }
    unless ( defined( $ARGV[1] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <get|set> ${CALLERID(num)} ${GROUP/QUEUE} ${UNIQUEID}',
            3
        );
        exit(-1);
    }
    unless ( defined( $ARGV[2] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <get|set> ${CALLERID(num)} ${GROUP/QUEUE} ${UNIQUEID}',
            3
        );
        exit(-1);
    }



	  my $sql = "insert into public.queue_parsed (callid,queue,time,callerid,agentid,status,success,holdtime,calltime,position) values (?,?,now(),?,?,?,0,0,0,0)"; 
		my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute ($ARGV[2], $ARGV[1], $ARGV[0], "IVR", "ABANDON"); };
    if ($@) { $this->agi->verbose( $this->dbh->errstr ); exit(-1); } 
    my $sql1 = "insert into queue_log (callid, queuename, agent, event, data , time ) values (?,?,'IVR','ABANDON','0|0|0',now())";
    my $sth1 = $this->dbh->prepare($sql1);
		eval { $sth1->execute ($ARGV[2], $ARGV[1]); };
		if ($@) { $this->agi->verbose( $this->dbh->errstr ); exit(-1); }
	  exit(0);
}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-addmissed.pl

=head1 SYNOPSIS

PearlPBX-addmissed.pl

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

