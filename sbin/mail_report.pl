#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  mail_report.pl
#
#        USAGE:  ./mail_report.pl
#
#  DESCRIPTION:  This script sends mail report about longest calls to users.
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  1.0
#      CREATED:  17.07.2023
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

MailReport->run(
	verbose => 1,
	has_conf => 1,
	conf_file   => "/etc/NetSDS/asterisk-router.conf",
	infinite    => 0,
);

1;

package MailReport;

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use DBI;
use Data::Dumper;
use Net::SMTP;
use NetSDS::Util::DateTime;
use Date::Simple;
use NetSDS::Util::String;
use MIME::Base64;

sub start {
    my $this = shift;
    $this->mk_accessors('dbh');
    $this->_db_connect();
}

sub _db_connect {
    my $this = shift;

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->speak("Can't find \"db main->dsn\" in configuration.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->speak("Can't find \"db main->login\" in configuraion.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->speak("Can't find \"db main->password\" in configuraion.");
        exit(-1);
    }

    my $dsn    = $this->conf->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->conf->{'db'}->{'main'}->{'login'};
    my $passwd = $this->conf->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->dbh or !$this->dbh->ping ) {
        $this->dbh(
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 , AutoCommit => 0 } ) );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }

	  return 1;
}

sub _get_data {
    my $this = shift;
    my $yesterday = shift;
    my $day_before_yesterday = shift;

    my $result_hashref;
    my $sql = "select c.calldate, c.src, c.dst, c.channel, c.duration, d.result_file from cdr c inner join integration.recordings d on c.calldate = d.cdr_start and c.src=d.cdr_src where  c.calldate between '$day_before_yesterday' and '$yesterday' order by duration desc limit 10;";
    print($sql . "\n");
	eval {
		$result_hashref = $this->dbh->selectall_hashref($sql, 'calldate');
	};
	if ($@) {
		die $this->dbh->errstr;
	}
	$this->dbh->rollback;

	return $result_hashref;

}

sub _mail {
    my $this = shift;
    my $body = shift;

    my $sendmail   = '/usr/sbin/sendmail';
    my $from       = $this->{conf}->{'email_from'};
    my $to         = $this->{conf}->{'email'};

    my $subject = 'Звіт про найдовші дзвінки за вчорашній день';
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

    return 1;
}

sub prepare_html {
    my $this = shift;
    my $data = shift;
    my $sorted_data = shift;

    my $output = "<table><thead><tr><th>Date and time</th>";
    $output .= "<th>Source</th><th>Channel</th><th>Duration</th><th>Link</th></tr></thead>";
    $output .= "<tbody>";

    foreach my $key (@{$sorted_data}) {
	$output .= "<tr>";

        my $record = $data->{$key};
        $output .= "<td>$record->{'calldate'}</td>";
        $output .= "<td>$record->{'src'}</td>";
	    $output .= "<td>$record->{'channel'}</td>";
        $output .= "<td>$record->{'duration'}</td>";
        $output .= "<td><a href=\"http://172.16.93.69/recordings/$record->{'result_file'}\">Download</a></td>";
        $output .= "</tr>";
    }

    $output .= "</tbody></table>";
    return $output;

}

sub process {
  my $this = shift;

  my $today = date_date(date_now());
  my $yesterday = Date::Simple->new($today) - 1;
  my $yesterday_ymd = $yesterday->format("%Y-%m-%d");
  my $data = $this->_get_data($today,$yesterday_ymd);
  my @sorted_data = sort { $data->{$a}->{'duration'} <=> $data->{$b}->{'duration'} } keys %$data;
  my $html = $this->prepare_html($data, \@sorted_data);
  $this->_mail($html);

  return 1;
}

1;
