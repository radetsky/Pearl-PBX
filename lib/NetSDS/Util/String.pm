#===============================================================================
#
#         FILE:  String.pm
#
#  DESCRIPTION:  Utilities for easy string processing
#
#         NOTE:  This module ported from Wono framework
#       AUTHOR:  Michael Bochkaryov (Rattler), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.044
#      CREATED:  03.08.2008 15:04:22 EEST
#===============================================================================

=head1 NAME

NetSDS::Util::String - string prcessing routines

=head1 SYNOPSIS

	use NetSDS::Util::String qw();

	# Read from standard input
	my $string = <STDIN>;

	# Encode string to internal structure
	$string = string_encode($tring);


=head1 DESCRIPTION

C<NetSDS::Util::String> module contains functions may be used to quickly solve
string processing tasks like parsing, recoding, formatting.

As in other NetSDS modules standard encoding is UTF-8.

=cut

package NetSDS::Util::String;

use 5.8.0;
use warnings 'all';
use strict;

use base 'Exporter';

use version; our $VERSION = '1.044';

our @EXPORT = qw(
  str_encode
  str_decode
  str_recode
  str_trim
  str_trim_left
  str_trim_right
  str_clean
  str_camelize
  str_decamelize
);

use POSIX;
use Encode qw(
  encode
  decode
  encode_utf8
  decode_utf8
  from_to
  is_utf8
);

my $BLANK = "[:blank:][:space:][:cntrl:]";

use constant DEFAULT_ENCODING => 'UTF-8';

#***********************************************************************
#
# ENCODING/DECODING/RECODING FUNCTIONS
#
#***********************************************************************

=head1 EXPORTED FUNCTIONS

=over

=item B<str_encode($str[, $encoding])> - encode string to internal UTF-8

By default this function treat first argument as byte string in UTF-8
and return it's internal Unicode representation.

In case of external character set isn't UTF-8 it should be added as second
argument of function.


	# Convert UTF-8 byte string to internal Unicode representation
	$uni_string = str_encode($byte_string);

	# Convert KOI8-U byte string to internal
	$uni_string = str_encode($koi8_string, 'KOI8-U');

After C<str_encode()> it's possible to process this string correctly
including regular expressions. All characters will be understood
as UTF-8 symbols instead of byte sequences.

=cut

#-----------------------------------------------------------------------
sub str_encode {
	my ( $txt, $enc ) = @_;

	if ( defined($txt) and ( $txt ne '' ) ) {
		unless ( is_utf8($txt) ) {
			$txt = decode( $enc || DEFAULT_ENCODING, $txt );
		}
	}

	return $txt;
}

#***********************************************************************

=item B<str_decode($str[, $encoding])> - decode internal UTF-8 to byte string

By default this function treat first argument as string in internal UTF-8
and return it in byte string (external) representation.

In case of external character set isn't UTF-8 it should be added as second
argument of function.


	# Get UTF-8 byte string from internal Unicode representation
	$byte_string = str_decode($uni_string);

	# Convert to KOI8-U byte string from internal Unicode
	$koi8_string = str_encode($uni_string, 'KOI8-U');

It's recommended to use C<str_encode()> when preparing data for
communication with external systems (especially networking).

=cut

#-----------------------------------------------------------------------
sub str_decode {
	my ( $txt, $enc ) = @_;

	if ( defined($txt) and ( $txt ne '' ) ) {
		if ( is_utf8($txt) ) {
			$txt = encode( $enc || DEFAULT_ENCODING, $txt );
		}
	}

	return $txt;
}

#***********************************************************************

=item B<str_recode($str, $FROM_ENC[, $TO_ENC])> - recode string

Translate string between different encodings.
If target encoding is not set UTF-8 used as default one.

=cut

#-----------------------------------------------------------------------
sub str_recode {
	my ( $txt, $enc, $trg ) = @_;

	if ( defined($txt) and ( $txt ne '' ) ) {
		if ($enc) {
			my $len = from_to( $txt, $enc, $trg || DEFAULT_ENCODING );
			unless ( defined($len) ) {
				$txt = undef;
			}
		}
	}

	return $txt;
}

#***********************************************************************
#
# CLEANING STRINGS
#
#***********************************************************************

=item B<str_trim($str)> - remove leading/trailing space characters

	$orig_str = "  string with spaces   ";
	$new_str = str_trim($orig_str);

	# Output: "string with spaces"
	print $new_str;

=cut

#-----------------------------------------------------------------------
sub str_trim {
	my ($s) = @_;

	if ( defined($s) and ( $s ne '' ) ) {
		$s =~ s/^[$BLANK]+//s;
		$s =~ s/[$BLANK]+$//s;
	}

	return $s;
}

#***********************************************************************

=item B<str_trim_left($str)> - removes leading whitespaces

This function is similar to C<str_trim()> except of it removes only
leading space characters and leave trailing ones.

=cut

#-----------------------------------------------------------------------
sub str_trim_left {
	my ($s) = @_ ? @_ : $_;

	if ( defined($s) and ( $s ne '' ) ) {
		$s =~ s/^[$BLANK]+//s;
	}

	return $s;
}

#***********************************************************************

=item B<str_trim_right($str)> - removes trailing whitespaces

This function is similar to C<str_trim()> except of it removes only
trailing space characters and leave leading ones.

=cut

#-----------------------------------------------------------------------
sub str_trim_right {
	my ($s) = @_ ? @_ : $_;

	if ( defined($s) and ( $s ne '' ) ) {
		$s =~ s/[$BLANK]+$//s;
	}

	return $s;
}

#***********************************************************************

=item B<str_clean($str)> - clean string from extra spaces

Function is similar to C<str_trim()> but also changes all spacing chains
inside string to single spaces.

=cut

#-----------------------------------------------------------------------
sub str_clean {

	my ($txt) = @_;

	if ( defined($txt) and ( $txt ne '' ) ) {
		$txt =~ s/^[$BLANK]+//s;
		$txt =~ s/[$BLANK]+$//s;
		$txt =~ s/[$BLANK]+/ /gs;
	}

	return $txt;
}

#**************************************************************************

=item B<str_camelize($strin)>

If pass undef - return undef.
If pass '' - return ''.

Examples:

	# returns 'getValue'
	str_camelize( 'get_value' )

	# returns 'addUserAction'
	str_camelize( 'ADD_User_actION' )

=cut

#-----------------------------------------------------------------------
sub str_camelize {

	my $s = shift;

	if ( defined($s) and ( $s ne '' ) ) {
		$s = lc($s);
		$s =~ s/_([0-9a-z])/\U$1/g;
	}

	return $s;
}

#**************************************************************************

=item B<str_decamelize(...)>

If pass undef - return undef.
If pass '' - return ''.

Examples:

	# returns 'get_value'
	str_decamelize( 'getValue' )

=cut

#-----------------------------------------------------------------------
sub str_decamelize {

	my $s = shift;

	$s =~ s/([A-Z])/_\L$1/g;

	return lc($s);
}

1;
__END__

=back

=head1 EXAMPLES

None yet

=head1 BUGS

Unknown yet

=head1 TODO

Implement examples and tests.

=head1 SEE ALSO

L<Encode>, L<perlunicode>

=head1 AUTHORS

Valentyn Solomko <pere@pere.org.ua>

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut
