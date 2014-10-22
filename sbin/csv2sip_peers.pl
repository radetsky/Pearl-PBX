#!/usr/bin/perl 

use strict; 
use warnings; 
use 5.8.0; 

use Data::Dumper; 
use DBI; 

# Need a one argument, file. 

my $c = @ARGV; 
unless ( $c == 1) { die "Where is my input file ?"; } 

open (my $in, $ARGV[0]) or die "Can't open $ARGV[0] : $!"; 
my $table = undef;  
my $peername = undef; 
while (my $line = <$in>) { 
	chomp $line; 
	if ($line =~ /\[(\w+)\]/) { 
		$peername = $1; 
		#print "\nPeerName $1: "; 
		next; 
		#warn Dumper $peername, $line; 
	}
	if ($line =~ /(\w+)=(.*)/) { 
		my $param = $1; 
		my $val = $2; 
		if (($param =~ /type/ ) or ($param =~ /secret/) or ($param =~ /host/)) { 
			$table->{$peername}->{$param} = $val; 
			#print "$param = $val "; 
		}
	}
}

foreach my $peer ( keys %{ $table } ) { 
	print "insert into sip_peers (name, secret, type, host ) values (\'".$peer."\', \'".$table->{$peer}->{'secret'}."\', \'".$table->{$peer}->{'type'}."\', \'".$table->{$peer}->{'host'}."\');\n"; 
}