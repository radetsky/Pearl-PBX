package PearlPBX::CRUD;

use warnings; 
use strict; 
use feature 'state'; 
use parent qw (Class::Accessor::Class);


# Connect to DB and return object 
sub new { 
  my $class = shift; 
  my $self  = undef; 

  $self = bless $self, $class; 
  $self->mk_accessors('dbh'); 
  $self->{db} = PearlPBX::DB->new(); 
  $self->dbh( $self->{db}->{dbh}); 

  return $self; 
}

sub paramsToConditionWithAnd { 
  my ($self, $params) = @_; 
  my @pairs;

  while ( my ($key, $value) = each %{$params} ) {
  	push @pairs, "$key=$value"; 
  }
  return join(' AND ', @pairs); 
}

1;
