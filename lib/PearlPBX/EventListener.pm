package PearlPBX::EventListener; 

use warnings; 
use strict; 

use parent qw(PearlPBX::Manager NetSDS::Asterisk::EventListener);

sub new {
    my $class = shift;

    my $this = PearlPBX::Manager->new('On');
    $this->{events}  = 'On';

    return bless $this;
}

1;
