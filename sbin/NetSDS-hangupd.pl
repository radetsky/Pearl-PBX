#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-hangupd.pl
#
#        USAGE:  ./NetSDS-hangupd.pl
#
#  DESCRIPTION:  Hangup daemon. Listens AMI for hangup events and clears the integration.ulines table.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  12/19/11 11:24:06 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

NetSDSHangupD->run(
    daemon      => 1,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef
);

1;

package NetSDSHangupD;

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use NetSDS::Asterisk::EventListener;
use Data::Dumper;

our @expire_list = (); 

sub start {
    my $this = shift;

    $SIG{TERM} = sub {
        exit(-1);
    };
    $SIG{INT} = sub {
        exit(-1);
    };

    $this->mk_accessors('el');
    $this->mk_accessors('dbh');

    $this->_db_connect();
    $this->_el_connect();

    $this->_clear_ulines();

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
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }

    return 1;
}

sub _el_connect {
    my $this = shift;

    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->speak("Can't file el->host in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->speak("Can't file el->port in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->speak("Can't file el->username in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->speak("Can't file el->secret in configuration.");
        exit(-1);
    }

    my $el_host     = $this->conf->{'el'}->{'host'};
    my $el_port     = $this->conf->{'el'}->{'port'};
    my $el_username = $this->conf->{'el'}->{'username'};
    my $el_secret   = $this->conf->{'el'}->{'secret'};

    my $event_listener = NetSDS::Asterisk::EventListener->new(
        host     => $el_host,
        port     => $el_port,
        username => $el_username,
        secret   => $el_secret
    );

    $event_listener->_connect();

    $this->el($event_listener);
}

sub _clear_ulines {
    my $this = shift;

    # connect
    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->speak("Can't file el->host in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->speak("Can't file el->port in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->speak("Can't file el->username in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->speak("Can't file el->secret in configuration.");
        exit(-1);
    }

    my $el_host     = $this->conf->{'el'}->{'host'};
    my $el_port     = $this->conf->{'el'}->{'port'};
    my $el_username = $this->conf->{'el'}->{'username'};
    my $el_secret   = $this->conf->{'el'}->{'secret'};

    my $manager = NetSDS::Asterisk::Manager->new(
        host     => $el_host,
        port     => $el_port,
        username => $el_username,
        secret   => $el_secret,
        events   => 'Off'
    );

    my $connected = $manager->connect;
    unless ( defined($connected) ) {
        $this->speak("Can't connect to the asterisk manager interface.");
        $this->log( "warning",
            "Can't connect to the asterisk manager interface." );
        exit(-1);
    }

    # get status

    my @liststatus = $this->_get_status($manager);
    my $busyulines = $this->_get_busy_ulines;

    #warn Dumper (\@liststatus);
    #warn Dumper ($busyulines);

    # compare channels with ulines
    my $id      = undef;
    my $channel = undef;
    my $found   = undef;

    foreach my $i ( @{$busyulines} ) {
        $id      = ${$i}[0];
        $channel = ${$i}[1];
        $found   = undef;
        foreach my $status (@liststatus) {
            if ( $status->{'Channel'} eq $channel ) {
                $found = 1;
                last;
            }
        }
        unless ( defined($found) ) {
            $this->_free_uline($channel);
        }
    }

    # clear offline channels

}

sub _get_status {
    my $this    = shift;
    my $manager = shift;

    my $sent = $manager->sendcommand( 'Action' => 'Status' );

    unless ( defined($sent) ) {
        return undef;
    }

    my $reply = $manager->receive_answer();

    unless ( defined($reply) ) {
        return undef;
    }

    my $status = $reply->{'Response'};

    unless ( defined($status) ) {
        return undef;
    }

    if ( $status ne 'Success' ) {
        $this->seterror('Status: Response not success');
        return undef;
    }

    # reading from spcket while did not receive Event: StatusComplete

    my @replies;
    while (1) {
        $reply  = $manager->receive_answer();
        $status = $reply->{'Event'};
        if ( $status eq 'StatusComplete' ) {
            last;
        }
        push @replies, $reply;
    }
    return @replies;

}

sub _get_busy_ulines {
    my $this = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
"select id,channel_name from integration.ulines where status='busy' order by id asc"
    );
    eval { my $rv = $sth->execute; };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $busylines = $sth->fetchall_arrayref;
    $this->dbh->commit;

    return $busylines;
}

sub _get_uline_by_channel { 
    my $this    = shift;
    my $channel = shift;

    $this->_begin;
    my $sth = $this->dbh->prepare(
        "select id from integration.ulines where channel_name=? and status='busy' order by id asc limit 1");
    eval { my $rv = $sth->execute($channel); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
	$this->dbh->rollback; 

	unless ( defined ( $result ) ) { 
		return undef; 
	}
	return $result->{'id'}; 	
}

sub _free_uline {
    my $this    = shift;
    my $channel = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
        "select id from integration.ulines where channel_name=? and status='busy' order by id asc limit 1 for update");

    eval { my $rv = $sth->execute($channel); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }

    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->log( "warning",
"XZ. Got hangup for channel $channel, but integration.ulines does not has it."
        );
        $this->dbh->rollback;
        return undef;
    }

	my $id = $result->{'id'};
	$this->log("info","Got ID = $id for update integration.ulines");
	$this->speak ("Got ID = $id for update integration.ulines");

    $sth = $this->dbh->prepare(
        "update integration.ulines set status='free' where id=?");
    eval { my $rv = $sth->execute($id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
    $this->log( "info", "uline $id with $channel cleared" );
    $this->speak("uline $id with $channel cleared");

    $this->_recording_set_final($id);

    return 1;
}

sub _recording_set_final {
    my $this     = shift;
    my $uline_id = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
"select id from integration.recordings where uline_id=? and next_record is NULL order by id desc limit 1"
    );
    eval { my $rv = $sth->execute($uline_id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->log( "warning",
            "Can't find recordings for uline_id=$uline_id. Very strange." );
        $this->dbh->rollback;
        return undef;
    }
    my $rec_id = $result->{'id'};
    $sth = $this->dbh->prepare(
        "update integration.recordings set next_record=0 where id=?");
    eval { my $rv = $sth->execute($rec_id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
    $this->log( "info", "Record # $rec_id for line # $uline_id set as final." );
    return 1;

}

sub _begin {
    my $this = shift;

    eval { $this->dbh->begin_work; };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->log( "error", $errstr );
    exit(-1);
}

sub _add_2_expire  { 
	my $this = shift; 
	my $channel = shift; 
	my $uline = shift; 
	my $expire_time = shift; 

	$this->log("info","added to expire list $uline $channel $expire_time"); 
	push @expire_list, { channel => $channel, uline => $uline, expire_time => $expire_time } ; 

}

sub _expire_ulines { 
	my $this = shift; 
	my $t = undef; 
	my $item = undef; 

	while (1) { 
		$t = time(); 
		$item = shift @expire_list; 
		unless ( $item ) { 
			$this->log("info","Empty expire list");
			return undef; 
		} 
		if ($item->{'expire_time'} < $t ) {
			$this->log("info","Time: $t to free uline $item->{'uline'} with $item->{'channel'}"); 
			$this->_free_uline ($item->{'channel'}); 
		} else { 
			$this->log("info","First item in the expire_list has time in future. "); 
			unshift @expire_list,$item; 
			return 1; 
		} 
	} 


}
sub process {
    my $this = shift;

    my $event   = undef;
    my $channel = undef;
	my $uline = undef; 

    while (1) {

        $event = $this->el->_getEvent();
        unless ($event) {
            sleep(1);
			$this->_expire_ulines();
            next;
        }

        unless ( defined( $event->{'Event'} ) ) {
            warn Dumper($event);
            next;
        }
        if ( $event->{'Event'} =~ /Hangup/i ) {

            $channel = $event->{'Channel'};
			$this->log("info","Got hangup for $channel"); 
			$uline = $this->_get_uline_by_channel ($channel); 
			unless ( defined ( $uline ) ) { 
				next; 
			}
			$this->_add_2_expire ($channel, $uline , time()+5);
		}
		$this->_expire_ulines();
    }

}

#===============================================================================

__END__

=head1 NAME

NetSDS-hangupd.pl

=head1 SYNOPSIS

NetSDS-hangupd.pl

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

