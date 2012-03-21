#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  stored_sessions.pl
#
#        USAGE:  ./stored_sessions.pl 
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
#      CREATED:  20.03.2012 18:13:17 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use DBI; 
use Pearl; 

my $pearl = Pearl->new; 
my $dbh = DBI->connect( "dbi:Pg:dbname=asterisk", 'asterisk', 'supersecret',
            { AutoCommit => 0, RaiseError => 1 } );

unless ( defined ( $dbh ) ) {
	$pearl->htmlError('DB Connection error!'); 
	exit(0);
}

my $dateFrom = $pearl->{cgi}->param('dateFrom');
unless ( $pearl->parseDate ($dateFrom) ) {
	$pearl->htmlError ( 'dateFrom regexp failed');  
	exit(0);
}

my $dateTo = $pearl->{cgi}->param('dateTo');
unless ( $pearl->parseDate ($dateTo) ) {
	$pearl->htmlError ( 'dateTo regexp failed');  
	exit(0);
}

my $timeFrom = $pearl->{cgi}->param('timeFrom');
unless ( $pearl->parseTime ($timeFrom) ) {
	$pearl->htmlError ( 'timeFrom regexp failed');  
	exit(0);
}

my $timeTo = $pearl->{cgi}->param('timeTo');
unless ( $pearl->parseTime ($timeTo) ) {
	$pearl->htmlError ( 'timeTo regexp failed');  
	exit(0);
}

my $phone = $pearl->{cgi}->param('phone'); 
unless ( $pearl->parsePhone ($phone) ) { 
	$pearl->htmlError ( 'Phone regexp error'); 
	exit(0);
}

my $query = "select id,cdr_start,cdr_src,cdr_dst,original_file,result_file 
							from integration.recordings 
							where cdr_start between ? and ? and 
							( cdr_src = ? or cdr_dst = ? or cdr_src like ? or cdr_dst like ?) 
							order by id desc"; 
my $sth;

eval { $sth = $dbh->prepare($query); };
if ($@) {
	$pearl->htmlError('SQL Prepare error: ' . $dbh->errstr); 
  exit(0); 
}

eval { $sth->execute ( $dateFrom.' '.$timeFrom, $dateTo.' '.$timeTo,
											$phone, $phone, '%phone%','%phone%'); 
		};
if ($@) { 
	$pearl->htmlError('SQL Execution error: ' . $dbh->errstr); 
	exit(0); 
}

my $result = $sth->fetchrow_hashref; 
unless ( defined ( $result ) ) { 
	$pearl->htmlError("No results found.");
	exit(0);
}

my $out; 

$out = "<table class=\"table table-stripped\">"; 
$out .= "<thead>"; 
$out .= "<tr>"; 
$out .= "<th>Дата/Время</th><th>Номер А</th><th>Номер Б</th><th>Запись</th><th>Склейка</th>";
$out .= "</tr>"; 
$out .= "</thead>";
$out .= "<tbody>"; 

	$out .= sprintf("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
		$result->{'cdr_start'},
		$result->{'cdr_src'},
		$result->{'cdr_dst'},
		_href_file($result->{'original_file'}),
		_href_file($result->{'result_file'}));

while ($result = $sth->fetchrow_hashref) { 
	$out .= sprintf("<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>",
		$result->{'cdr_start'},
		$result->{'cdr_src'},
		$result->{'cdr_dst'},
		_href_file($result->{'original_file'}),
		_href_file($result->{'result_file'}));
}


$out .= "</tbody>"; 
$out .= "</table>";

$pearl->htmlHeader; 

print $out; 
exit(0);

sub _href_file { 
	my $filename = shift; 

	my ($year,$mon,$day,$time_src) = split('/',$filename);
	my $link = "/recordings/$filename";
	my $out = "<a href=\"$link\">$time_src<a>";
	return $out; 
}


1;
#===============================================================================

__END__

=head1 NAME

stored_sessions.pl

=head1 SYNOPSIS

stored_sessions.pl

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

