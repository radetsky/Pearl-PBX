#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  removedublicatefromqueuelog.pl
#
#        USAGE:  ./removedublicatefromqueuelog.pl 
#
#  DESCRIPTION:  Удаляет дубликаты записей за указанный период в указанной базе данных и таблице public.queue_log 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  04.10.2012 11:20:00 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use DBI;

my $db_host = $ARGV[0]; 
my $db_user = $ARGV[1]; 
my $db_pass = $ARGV[2]; 
my $db_db   = $ARGV[3]; 

my $fromdate = $ARGV[4]; 
my $tilldate = $ARGV[5]; 

unless ( defined ( $db_host ) ) { usage(); }
unless ( defined ( $db_user ) ) { usage(); }
unless ( defined ( $db_pass ) ) { usage(); }
unless ( defined ( $db_db   ) ) { usage(); } 
unless ( defined ( $fromdate ) ) { usage(); }
unless ( defined ( $tilldate ) ) { usage(); } 

my $dbh = db_connect($db_host,$db_user,$db_pass,$db_db ); 
unless (defined ( $dbh ) ) { 
	die DBI::errstr; 
} 

$dbh->begin_work; 

# Connected. Fetch all records with given period 
my $sql = "select * from public.queue_log where time between ? and ? order by time, id"; 
my $sth = $dbh->prepare ($sql); 
eval { $sth->execute($fromdate,$tilldate); }; 
if ( $@ ) { 
	die $dbh->errstr; 
}

my @rows; 

while (my $row = $sth->fetchrow_hashref) { 
	push @rows, $row;
	print "fetch: ".$row->{id}. " " . $row->{time} . " " . $row->{event}. "\n"; 
} 
$dbh->commit; 

$dbh->begin_work; 

foreach my $row (@rows) {
	my @dubs = grep { is_dub ($row, $_); } @rows; 
  foreach my $dub ( @dubs ) { 
		print "delete: ".$dub->{id}." which is dub to ".$row->{id}."\n";
		$dbh->do("delete from public.queue_log where id=".$dub->{id});  
		@rows = grep {  $_->{'id'} ne $dub->{'id'}  } @rows; 
	} 
} 

$dbh->commit; 

foreach my $row (@rows) { 
	print $row->{'id'} . " " . $row->{'time'} . "\n"; 
} 


#-------------------------------------------------------------------------------
sub is_dub { 
	my ($row, $dub) = @_; 
	
	if ($row->{id} eq $dub->{id} ) { return undef; } 


	if ( ( $row->{callid} eq $dub->{callid} ) and 
		   ( $row->{time} eq $dub->{time} ) and 
			 ( $row->{queuename} eq $dub->{queuename} ) and 
			 ( $row->{agent} eq $dub->{agent} ) and 
			 ( $row->{event} eq $dub->{event} ) and 
			 ( $row->{data} eq $dub->{data} ) ) { 
			 return $row;   
	} 
	return undef; 

}
sub db_connect { 
	my ($db_host,$db_user,$db_pass,$db_db) = @_; 
	
	my $dbh = DBI->connect("dbi:Pg:dbname=$db_db;host=$db_host",$db_user,$db_pass, 
		{ RaiseError => 1 } ); 
		
	return $dbh; 
}

sub usage { 

die "Usage: $0 <db_host> <db_user> <db_password> <db_name> <fromdate> <tilldate>\n";   

} 

1;
#===============================================================================

__END__

=head1 NAME

removedublicatefromqueuelog.pl

=head1 SYNOPSIS

removedublicatefromqueuelog.pl

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

