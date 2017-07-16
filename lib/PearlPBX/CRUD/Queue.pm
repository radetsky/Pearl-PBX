package PearlPBX::CRUD::Queue;

use warnings;
use strict;

use parent qw(PearlPBX::CRUD);

=cut

=head1 NAME

    PearlPBX::CRUD::Queue - Class for manipulating asterisk queues places in DBI/public.queues;

=head1 SYNOPSIS

    use PearlPBX::CRUD::Queue;

    my $queue = PearlPBX::CRUD::Queue->create(
        name       => 'testQueue',
        strategy   => 'ringall',
        timeout    => 15,
        maxlen     => 1,
    );

=head1 DESCRIPTION



=head1 Methods

=over

=item B<create($options)>

Create a new queue and insert it into DB
Return hashref { result => 'ok' }

=item B<update($options)>

Update according queue fields in DB with name=$options->name.
Return hashref { result => 'ok' } or { error => 'Unknown error of confirmation code' }

=item B<read($options)>

Read queue from DB with options
Return hashref { result => 'ok', data => {  name => 'testQueue',
										    strategy => 'ringall',
										    timeout => 15,
										    maxlen => 5 }};


=back

=cut

use constant QUEUES => 'public.queues';

sub create {
	my $self   = shift;
	my $params = shift;

}

sub update {
	my $self   = shift;
	my $params = shift;
    my $qname  = shift;

    my $setParams = $self->paramsToSetParams($params);
    my $sql = "update ".QUEUES. " set ". $setParams . "where name=?";
    my $sth = $self->dbh->prepare($sql);
    $sth->execute($qname);
}

sub read {
	my $self   = shift;
	my $params = shift;

	my $sql = "select * from ".QUEUES;
    if (defined ( $params ) ) {
        my $condition = $self->paramsToConditionWithAnd($params);
        $sql .= " where " . $condition;
    }

	my $sth = $self->dbh->prepare($sql);
	my $rv = $sth->execute();
	my $result = $sth->fetchall_hashref('name');
	return $result;

}

sub delete {
	my $params = shift;

}

1;

