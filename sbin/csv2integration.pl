#!/usr/bin/perl 

# Результат этого скрипта можно послать следующим способом:
# curl -X POST -H "Content-Type: text/xml" --data-binary @myfile http://sms.pharos.com.ua/api/bulk_sm_async 
#


use strict; 
use warnings; 
use 5.8.0; 

use Data::Dumper; 
use DBI; 

# Need a one argument, file. 

my $c = @ARGV; 
unless ( $c == 1) { die "Where is my input file ?"; } 

open (my $in, $ARGV[0]) or die "Can't open $ARGV[0] : $!"; 
my $id = 0; 
while (my $line = <$in>) { 
	chomp $line; 
	$id = $id + 1; 
	my ($model, $macaddr, $sip_name) = split ("," , $line); 
	print "update integration.workplaces set mac_addr_tel = '".$macaddr."', autoprovision='t', teletype='".$model."' where sip_id in ( select id from public.sip_peers where name='".$sip_name."');\n"; 
}
