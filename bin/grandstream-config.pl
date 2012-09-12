#!/usr/bin/perl -w
use strict;

# Posted on http://lists.digium.com/pipermail/asterisk-users/2004-September/063515.html
# Bugfixes by Lionel Elie Mamane <lionel@mamane.lu>:
#  - Properly url-encode values
#  - Don't remove whitespace from values (only leading and trailing)

my $h_mac  = shift ; # '000b8203ce2b' # hexadecimal mac address
my $f_in   = shift ; # 'config.txt' # file body, configfile containing all parameters
my $f_out  = shift ; # 'cfg.out' # the configfile that will be written to

my $h_crlf = '0d0a';         # hexadecimal crlf

# convert some things to binary
my $b_mac  = pack("H12", $h_mac); # convert 12 hex numbers to bin
my $b_crlf = pack("H4", $h_crlf); # convert 4 hex numbers to bin

# open configfile and make body in ascii (a_body)
my $a_body;
open F,$f_in;
while (<F>) {
    chomp;      # remove trailing lf
    s/\#.*$//;  # remove comments
    s/^\s*//;   # remove all leading whitespace
    s/\s*$//;   # remove all trailing whitespace
    if ( $_ ) {
	my $val;
	s/\s*=\s*(.*)/=/; # separate key (in $_) and value (in $1), dropping whitespace around =
	$val = $1;
	$val =~ s/([^A-Za-z0-9._-])/sprintf("%%%02X", ord($1))/seg; #URL-encode value
	$_ .= $val;
    }
    $a_body .= $_.'&' if length > 0;
}
close F;
$a_body .='gnkey=0b82';

# add an extra byte to make the body even (bytewise)
$a_body .= "\0" if ((length($a_body) % 2) ne 0);

# add an extra word ( = two bytes) to make the body even (wordwise)
$a_body .= "\0\0" if ((length($a_body) % 4) ne 0);

# generate a d_length (length of the complete message, counting words, in dec)
# ( header is always 8 words lang ) + ( body in ascii (bytes) / 2 = in words )
my $d_length = 8 + (length($a_body)/2);

# make that a binary dword
my $b_length = pack("N", $d_length);

# generate a checksum
my $d_checksum;
foreach ($b_length,$b_mac,$b_crlf,$b_crlf,$a_body) {
        $d_checksum += unpack("%16n*", $_);
}
#$d_checksum %= 65536;

$d_checksum = 65536-$d_checksum;

# and make a binary word of that
my $b_checksum = pack("n", $d_checksum);

# and write the config back to disk, in a grandstream readable format
open F,">$f_out";
binmode F;
print F $b_length;
print F $b_checksum;
print F $b_mac;
print F $b_crlf;
print F $b_crlf;
print F $a_body;
close F;
