#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-callbackd.pl
#
#        USAGE:  ./PearlPBX-callbackd.pl [ --verbose ]
#
#  DESCRIPTION:  Find undone callback applications and try to resolv it from CDR. 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Radetsky 
#      VERSION:  1.0
#      CREATED:  12/31/11 09:44:14 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

PearlPBXRecd->run(
    daemon      => undef,
    verbose     => 0,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef,
);

1;

package PearlPBXRecd;

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use Data::Dumper;
use NetSDS::Util::File;

sub start {
    my $this = shift;

    $SIG{TERM} = sub {
        exit(-1);
    };
    $SIG{INT} = sub {
        exit(-1);
    };

    $this->mk_accessors('dbh');
    $this->_db_connect();

    $this->{'bad_id'} = 0; 

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

    $this->log("warning", $errstr );
    exit(-1);
}

sub _get_today_undone {
    my $this       = shift;

    # remember - transaction already began;
    # Find all undone applications for last 24 hours 
    my $sth = $this->dbh->prepare(
        "select * from callback_list where created between now()-'1 day'::interval and now() and not done");

    eval { $sth->execute(); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchall_hashref('id');
    return $result;
}

sub _find_done { 
    my ($this, $cb) = @_; 

    my $created = $cb->{'created'}; 
    my $callerid = $cb->{'callerid'}; 

    my $sql = "select * from cdr where calldate between ? and now() and dst=? and disposition='ANSWERED' order by calldate limit 1"; 
    my $sth = $this->dbh->prepare($sql); 
    eval { $sth->execute($created,$callerid); }; 
    if ( $@ ) { $this->_exit( $this->dbh->errstr ); } 
    my $result = $sth->fetchrow_hashref; 
    return $result; 
}
sub _cutoff_channel {
    my $this    = shift;
    my $channel = shift;
    my ( $proto, $a ) = split( '/', $channel );
    my ( $peername, $channel_number ) = split( '-', $a );

    return $peername;
}

sub _update_done { 
    my ($this,$cb,$done) = @_; 

    my $sql = "update public.callback_list set done='t', operator=? where id=?"; 
    my $sth = $this->dbh->prepare($sql);

    my $operator = $this->_cutoff_channel($done->{'channel'}); 

    eval { $sth->execute($operator, $cb->{'id'} ); }; 
    if ( $@ ) { $this->_exit( $this->dbh->errstr ); }
    
    warn "Applied done to " . $cb->{'created'} . " " . $cb->{'callerid'} . " by " . $operator; 
} 

sub process {
    my $this = shift;

    my $result = $this->_get_today_undone(); 
    #warn Dumper ($result);

    foreach my $id ( sort keys %{ $result } ) {  
	my $cb_app = $result->{$id};
	warn "Searching for outgoing call to ".Dumper ($cb_app->{'callerid'});  
        my $done = $this->_find_done ($cb_app); 
	if ( $done ) { 
	    $this->_update_done($cb_app, $done);  		
	}
    }
}

1;

#===============================================================================

__END__

=head1 NAME

NetSDS-callbackd.pl

=head1 SYNOPSIS

NetSDS-callbackd.pl

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

