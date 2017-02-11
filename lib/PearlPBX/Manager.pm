package PearlPBX::Manager;

use warnings;
use strict;

use parent qw(NetSDS::Asterisk::Manager);

use PearlPBX::Logger; 
use PearlPBX::Config qw(conf);

sub new {
	my $class = shift;
	my $this; 
	$this->{conf} = conf();
	$this->_check_manager_configuration();

	my $this = bless {}, $class; 

	$this->SUPER::new ( 
		host => $this->{conf}->{el}->{host}, 
		port => $this->{conf}->{el}->{port},
		username => $this->{conf}->{el}->{username},
		secret => $this->{conf}->{el}->{secret},
	); 
	$this->connect; 

	return $this; 

}

sub _check_manager_configuration {
    my $this = shift;

    unless ( defined( $this->{conf}->{'el'}->{'host'} ) ) {
        die ("Can't file el->host in configuration.\n");
    }
    unless ( defined( $this->{conf}->{'el'}->{'port'} ) ) {
        die ("Can't file el->port in configuration.\n");
    }
    unless ( defined( $this->{conf}->{'el'}->{'username'} ) ) {
        die ("Can't file el->username in configuration.\n");
    }
    unless ( defined( $this->{conf}->{'el'}->{'secret'} ) ) {
        die ("Can't file el->secret in configuration.\n");
    }

}