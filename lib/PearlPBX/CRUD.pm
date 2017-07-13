package PearlPBX::CRUD;

use warnings;
use strict;
use feature 'state';
use parent qw (Class::Accessor::Class);

use PearlPBX::DB;
use constant PBXCFG => "pearlpbx.conf";

# Connect to DB and return object
sub new {
  my $class = shift;
  my $self  = undef;

  $self->{db} = PearlPBX::DB->new(PBXCFG);

  $self = bless $self, $class;
  $self->mk_accessors('dbh');
  $self->dbh( $self->{db}->{dbh});

  return $self;
}

sub paramsToConditionWithAnd {
  my ($self, $params) = @_;
  my @pairs;

  while ( my ($key, $value) = each %{$params} ) {
  	push @pairs, "$key=\'$value\'";
  }
  return join(' AND ', @pairs);
}

sub paramsToSetParams {
  my ($self, $params) = @_;
  my @pairs;

  while ( my ( $key, $value) = each %{$params} ) {
    push @pairs, "$key=\'$value\'";
  }
  return join(',', @pairs);
}

1;
