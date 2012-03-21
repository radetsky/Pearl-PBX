#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  cdr2recordings.pl
#
#        USAGE:  ./cdr2recordings.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  20.03.2012 23:25:14 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use DBI;

my $dbh =  DBI->connect( "dbi:Pg:dbname=asterisk", 'asterisk', 'supersecret',
            { AutoCommit => 1, RaiseError => 1 } );

my $query1 = "select id,original_file from integration.recordings order by id"; 
my $sth1 = $dbh->prepare($query1);

my $query2 = "select calldate,src,dst from public.cdr where calldate=? and src=?";
my $sth2 = $dbh->prepare($query2);

my $query3 = "update integration.recordings set cdr_start=?,cdr_src=?,cdr_dst=? where id=?";
my $sth3 = $dbh->prepare($query3);

# 1. Fetch all original_file into memory 

my $rv = $sth1->execute(); 
my $original_files = $sth1->fetchall_hashref('id');
my $count1 = keys %$original_files; 
my $calldate = undef; 
my $src = undef; 
my $count2 = 0;
$dbh->rollback();

foreach my $id ( keys %$original_files ) { 
	$count2++; 
	($calldate,$src) = _filename2calldate($original_files->{$id}->{'original_file'}); 
	printf("%d/%d %10s %s %s %s\n",$count2,$count1,$id ,$original_files->{$id}->{'original_file'},$calldate,$src);
	$rv = $sth2->execute($calldate,$src);
	my $row = $sth2->fetchrow_hashref();
	unless ( defined ($row) ) { 
		warn "Can't find cdr with $calldate and $src"; 	
		next;
	}
	$sth3->execute($row->{'calldate'},$row->{'src'},$row->{'dst'},$id);

}

exit(0);

sub _filename2calldate { 
	my $filename = shift; 

	$filename =~ /^(\d{4})\/(\d{2})\/(\d{2})\/(\d{6})-(.*)\.wav$/; 
	my $time = _six2time($4);	
	return ("$1-$2-$3 $time",$5);

}

sub _six2time { 
	my $six = shift; 

	my $hour = substr ($six,0,2);
	my $min = substr ($six,2,2);
	my $sec = substr ($six,4,2);

	return join (':',$hour,$min,$sec);
}

1;
#===============================================================================

__END__

=head1 NAME

cdr2recordings.pl

=head1 SYNOPSIS

cdr2recordings.pl

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

