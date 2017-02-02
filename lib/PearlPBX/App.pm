package PearlPBX::App; 

use warnings;
use strict;

use base qw(NetSDS::App);
use NetSDS::Asterisk::EventListener;
use NetSDS::Asterisk::Manager;
use Data::Dumper;
use LWP::UserAgent;

sub start {
	my $this = shift; 

	$this->SUPER::start();

    $SIG{TERM} = sub {
        exit(-1);
    };
    $SIG{INT} = sub {
        exit(-1);
    };

    $this->mk_accessors('el');
    $this->mk_accessors('mgr');
    $this->mk_accessors('dbh');

    $this->_db_connect();
    $this->_el_connect();
    $this->_manager_connect();

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
        $this->speak ( "Database connected." );
    }

    return 1;
}

sub _check_manager_configuration {
    my $this = shift;

    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->_exit("Can't file el->host in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->_exit("Can't file el->port in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->_exit("Can't file el->username in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->_exit("Can't file el->secret in configuration.");
    }

}

sub _el_connect {
    my $this = shift;

    $this->_check_manager_configuration();

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

    $event_listener->connect();

    $this->el($event_listener);
}

sub _manager_connect {
    my $this = shift;

    $this->_check_manager_configuration();

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

    unless ( defined ( $connected ) ) {
        $this->_exit("Can't connect to the asterisk manager interface.");
    }

    $this->mgr($manager); 
    
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->log( "error", $errstr );
    if ( $this->verbose ) {
    	$this->speak($errstr);
    }
    exit(-1);
}

sub _begin {
    my $this = shift;

    eval { $this->dbh->begin_work; };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
}

1;
