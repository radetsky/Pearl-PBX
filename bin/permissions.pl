#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  permissions.pl
#
#        USAGE:  ./permissions.pl 
#
#  DESCRIPTION:  Permit all calls 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  11.09.2012 15:52:33 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

Permissions->run(    
	  conf_file   => '/etc/NetSDS/asterisk-router.conf',
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1; 

package Permissions; 

use base 'NetSDS::App'; 

sub start {
    my $this = shift;

    $this->mk_accessors('dbh');

    $this->_db_connect;
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
    if ( $this->{verbose} ) {
        $this->agi->verbose( "Database connected.", 3 );
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

sub process { 
	  my $this = shift; 

	  my $sql = "select id from public.sip_peers order by id"; 
	  my $sth = $this->{'dbh'}->prepare($sql);
	  $sql = "select dlist_id from routing.directions_list order by dlist_id"; 
		my $sth2 = $this->{'dbh'}->prepare($sql);
		$sql = "insert into routing.permissions (direction_id,peer_id) values ( ?, ?)"; 
		my $sth3 = $this->{'dbh'}->prepare($sql); 
		eval { 
			$sth->execute();
		}; 
		if ( $@) { 
			die "sth1 failed"; 
		}
		my @peers;
		my @directions; 

		while (my $peer = $sth->fetchrow_hashref ) { 
			push @peers, $peer->{'id'};
	  	}

		eval { $sth2->execute(); } or die  "sth2 failed";
 
		while ( my $dir = $sth2->fetchrow_hashref ) { 
			push @directions, $dir->{'dlist_id'}; 
		}

		foreach my $sip_id (@peers ) { 
			foreach my $dlist_id (@directions) { 
				print "dlist_id=$dlist_id sip_id=$sip_id\n"; 
				eval { $sth3->execute($dlist_id, $sip_id); } or die "sth3 failed"; 
		  }
		}
	
		$this->{'dbh'}->commit;
 

}



1;
#===============================================================================

__END__

=head1 NAME

permissions.pl

=head1 SYNOPSIS

permissions.pl

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

