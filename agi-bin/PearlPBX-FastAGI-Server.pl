#!/usr/bin/env perl

use 5.8.0;
use strict;
use warnings;

$| = 1;

FastServer->run(
    port        => '4573',
);

1;

package FastServer;

use base 'Asterisk::FastAGI';
use DBI;

sub _db_connect {
    my $this = shift;

    my $dsn    = 'dbi:Pg:dbname=asterisk;host=127.0.0.1';
    my $user   = 'asterisk';
    my $passwd = 'supersecret';

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->{dbh} or !$this->{dbh}->ping ) {
        $this->{dbh} = DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } );
    }

    if ( !$this->{dbh} ) {
        exit(-1);
    }

    return 1;
}

sub child_init_hook {
    my $this = shift;

    $this->{dbh} = undef;
    $this->_db_connect();

}

sub _cut_the_plus {
    my $this = shift;
    my $str  = shift;

    my $first = substr( $str, 0, 1 );
    if ( $first eq '+' ) {
        return substr( $str, 1 );
    } else {
        return $str;
    }
}

sub _cut_local_callerid {
    my $this     = shift;
    my $callerid = shift;

    my $local_country_code  = '38';
    my $local_number_length = 10;

    my $calleridlen = length($callerid);
    if ( $calleridlen > $local_number_length ) {
        # Длина входящего номера больше чем длина национального,
        # Значит будем обрезать.
        if ( $callerid =~ /^$local_country_code/ ) {
            # Еще и попал под regexp с началом номера с национального кода ?
            # Точно будем обрезать
            $callerid = substr( $callerid, $calleridlen - $local_number_length, $local_number_length );
        }
    } elsif ( $calleridlen == $local_number_length-1 ) {
        $callerid = "0".$callerid;
    }
    return $callerid;
}

sub _normalize_callerid {
    my $this = shift;
    my $param = shift;

    my $callerid = $this->_cut_the_plus($param);
    $callerid = $this->_cut_local_callerid($callerid);

    return $callerid;
}

sub blacklist {
	my $this = shift;

    my $callerid_num = $this->param('callerid_num');
    unless ( defined ( $callerid_num ) ) {
        return;
    }

    $callerid_num = $this->_normalize_callerid ( $callerid_num );
#    warn $callerid_num . "\n";

    my $sql = "select count(*) as blacklisted from public.blacklist where number=?";
    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute ( $callerid_num ); };
    if ( $@ ) {
       return undef;
    }

	my $res = $sth->fetchrow_hashref;
    my $blacklisted = $res->{'blacklisted'};

    if ( $blacklisted > 0 ) {
		$this->agi->hangup();
	}

    return 1;
}

1;

