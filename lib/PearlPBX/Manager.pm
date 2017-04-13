package PearlPBX::Manager;

use warnings;
use strict;

use parent qw(NetSDS::Asterisk::Manager);

use PearlPBX::Logger;
use PearlPBX::Config qw(conf);
use Data::Dumper;

sub new {
	my $class = shift;
    my $events = shift; 
	my $conf = conf();

    _check_manager_configuration($conf);

	my $this = $class->SUPER::new (
		host => $conf->{el}->{host},
		port => $conf->{el}->{port},
		username => $conf->{el}->{username},
		secret => $conf->{el}->{secret},
    );

	$this->{events} = $events // 'Off'; 

    my $connected = $this->connect;
    unless ( defined ( $connected ) ) {
        die $this->geterror;
    }

    return bless $this, $class;
}

sub _check_manager_configuration {
    my $conf = shift;

    unless ( defined( $conf->{'el'}->{'host'} ) ) {
        die ("Can't find el->host in configuration.\n");
    }
    unless ( defined( $conf->{'el'}->{'port'} ) ) {
        die ("Can't fnd el->port in configuration.\n");
    }
    unless ( defined( $conf->{'el'}->{'username'} ) ) {
        die ("Can't fnd el->username in configuration.\n");
    }
    unless ( defined( $conf->{'el'}->{'secret'} ) ) {
        die ("Can't find el->secret in configuration.\n");
    }

}
1;

