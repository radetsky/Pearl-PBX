#!/usr/bin/env perl

use 5.8.0;
use strict;
use warnings;

$| = 1;

FastServer->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => 1,
    verbose     => undef,
    debug       => 1,
    infinite    => undef,
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

sub blacklist {
	my $this = shift;

    my $callerid_num = $this->param('callerid_num');
    unless ( defined ( $callerid_num ) ) {
        return;
    }

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

