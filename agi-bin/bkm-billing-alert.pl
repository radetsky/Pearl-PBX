#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  bkm-billing-alert.pl
#
#        USAGE:  bkm-billing-alert.pl <phone number>
#
#  DESCRIPTION:  Check BKM billing for an alert on the network 
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  1.0
#      CREATED:  27.08.2018 
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

BKMAlert->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1, 
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;
 
package BKMAlert; 
use base 'PearlPBX::IVR'; 
use IO::Socket;
use IO::Select;
use POSIX;
use bytes;

use constant BKM_HOST => '91.192.152.80';
use constant BKM_PORT => '5552'; 

sub process { 
	my $this = shift; 

	unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose("Usage: " . $this->name . ' ${CALLERID(num)}', 3);
        exit(-1);
    }

    $this->agi->set_variable("BKMALERT","0");

    my $socket = IO::Socket::INET->new(
        PeerAddr  => BKM_HOST,
        PeerPort  => BKM_PORT,
        Proto     => "tcp",
        Timeout   => 30,
        Type      => SOCK_STREAM(),
        ReuseAddr => 1,
    );

    unless ( $socket and $socket->connected ) {
        $this->agi->verbose("Can't connect to BKM_HOST:BKM_PORT", 3);
        exit(0);
    }
    $socket->autoflush(1);
    
    $socket->print($ARGV[0]);
    $socket->print("\n");

    my $result = $socket->getline; 
    chomp $result;
    $this->agi->set_variable("BKMALERT",$result);     

    $socket->close(); 

    exit(0);
}

1;
#===============================================================================
