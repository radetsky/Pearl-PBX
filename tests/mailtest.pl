#!/usr/bin/env perl 

use strict;
use warnings;
use 5.8.0;

use MIME::Base64; 
use NetSDS::Util::DateTime;

my $sendmail   = '/usr/sbin/sendmail';
my $from       = 'pearlpbx@pearlpbx.com';
my $to         = 'rad@rad.kiev.ua';

my $subject = 'Пропущенный звонок с номера: 0504139380';
my $body = "С уважением, PearlPBX\n";

#utf8::encode($subject);
$subject = encode_base64($subject,'');
$body = encode_base64($body);

open( MAIL, "| $sendmail -t -oi" ) or die("$!");

print MAIL <<EOF;
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64
From: $from
To: $to
Subject: =?UTF-8?B?$subject?=

$body
EOF

close MAIL;



