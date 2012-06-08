#===============================================================================
#
#         FILE:  DateTime.pm
#
#  DESCRIPTION:  Common date/time processing utilities for NetSDS
#
#       AUTHOR:  Michael Bochkaryov (Rattler), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      CREATED:  25.04.2008 15:55:01 EEST
#===============================================================================

=head1 NAME

NetSDS::Util::DateTime - common date/time processing routines

=head1 SYNOPSIS

	use NetSDS::Util::DateTime;

	print "Current date: " . date_now();

=head1 DESCRIPTION

This package provides set of routines for date and time processing.

=cut

package NetSDS::Util::DateTime;

use 5.8.0;
use strict;
use warnings;

use base 'Exporter';

use version; our $VERSION = '1.044';

our @EXPORT = qw(
  date_now_array
  date_now
  date_now_iso8601
  date_strip
  date_date
  date_time
  time_from_string
  date_from_string
  date_inc
  date_inc_string
);

use POSIX;
use Time::Local;
use Time::HiRes qw(gettimeofday);

# Include parsing/formatting modules
use HTTP::Date qw(parse_date);
use Date::Parse qw(str2time);
use Date::Format qw(time2str);

#===============================================================================

=head1 EXPORTED FUNCTIONS

=over

=item B<date_now_array([TIME])>

Returns array of date items for given date.
If source date is not set current date used.

=cut

#-----------------------------------------------------------------------
sub date_now_array {
	my ( $sec, $min, $hor, $mdy, $mon, $yer ) = localtime( (@_) ? $_[0] : time );

	return ( $yer + 1900, $mon + 1, $mdy, $hor, $min, $sec );
}

#***********************************************************************

=item B<date_now([TIME])>

Return [given] date as string.

    2001-12-23 14:39:53

=cut

#-----------------------------------------------------------------------
sub date_now {
	my ( $tm, $zn ) = @_;

	return ($zn)
	  ? time2str( "%Y-%m-%d %T %z", $tm || time )
	  : time2str( "%Y-%m-%d %T", $tm || time );
}

#***********************************************************************

=item B<date_now_iso8601([TIME])>

Return date as ISO 8601 string.

    20011223T14:39:53Z

L<http://en.wikipedia.org/wiki/ISO_8601>
L<http://www.w3.org/TR/NOTE-datetime>

=cut

#-----------------------------------------------------------------------
sub date_now_iso8601 {
	my ($tm) = @_;

	return time2str( "%Y%m%dT%H%M%S%z", $tm || time );
}

#***********************************************************************

=item B<date_strip(DATE)>

Trim miliseconds from date.

=cut

#-----------------------------------------------------------------------
sub date_strip {
	my ($date) = @_;

	$date =~ s/\.\d+// if ($date);

	return $date;
}

#***********************************************************************

=item B<date_date(DATE)>

Trim time part from date.

=cut

#-----------------------------------------------------------------------
sub date_date {
	my ($date) = @_;

	$date =~ s/[\sT]+.+$// if ($date);

	return $date;
}
#***********************************************************************

=item B<date_time(DATE)>

Trim date part from date.

=cut

#-----------------------------------------------------------------------

sub date_time { 
	my ($date) = @_; 

	unless ( defined ($date) ) { 
		return undef; 
	}

	my ($dateonly, $time) = split (/ /, $date); 

	return $time; 
} 

#***********************************************************************

=item B<time_from_string($string)>

Return parsed date/time structure.

=cut

#-----------------------------------------------------------------------
sub time_from_string {
	my ($str) = @_;

	unless ($str) {
		return undef;
	}

	my $tm = Date::Parse::str2time($str);
	if ($tm) {
		return $tm;
	}

	$tm = parse_date($str);
	if ($tm) {
		return Date::Parse::str2time($tm);
	}

	return undef;
}

#***********************************************************************

=item B<date_from_string($string)>

Return date from string representation.

=cut

#-----------------------------------------------------------------------
sub date_from_string {
	my ($str) = @_;

	return date_now( time_from_string($str) );
}

#***********************************************************************

=item B<date_inc([INCREMENT, [TIME]])>

Return date incremented with given number of seconds.

=cut

#-----------------------------------------------------------------------
sub date_inc {
	my ( $inc, $tm ) = @_;
	$tm ||= time;

	return date_now( $tm + $inc );
}

#***********************************************************************

=item B<date_inc_string([INCREMENT, [TIME]])>

Return string representation of date incremented with given number of seconds.

=cut

#-----------------------------------------------------------------------
sub date_inc_string {
	my ( $inc, $tm ) = @_;

	return ($tm) ? date_inc( $inc, time_from_string($tm) ) : date_inc($inc);
}

1;

__END__

=back

=head1 EXAMPLES

None yet

=head1 BUGS

Unknown yet

=head1 SEE ALSO

L<Date::Parse>, L<Date::Format>

=head1 TODO

Import stuff from Wono project

=head1 AUTHOR

Valentyn Solomko <val@pere.org.ua>

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut


