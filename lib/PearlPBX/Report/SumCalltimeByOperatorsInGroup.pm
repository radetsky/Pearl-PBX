#===============================================================================
#
#         FILE:  SumCalltimeByOperatorsInGroup.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  28.06.2012 05:30:27 EEST
#===============================================================================

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Report::SumCalltimeByOperatorsInGroup;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON; 

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

#===============================================================================
#

=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

#***********************************************************************

=head1 OBJECT METHODS

=over

=item B<user(...)> - object method

=cut

#-----------------------------------------------------------------------
sub report {
    my $this = shift;
	my $params = shift;

    my $sincedatetime = $this->filldatetime( $params->{'dateFrom'}, $params->{'timeFrom'} );
    my $tilldatetime  = $this->filldatetime( $params->{'dateTo'},  $params->{'timeTo'} );
    my $queue = $params->{'queue'};

    my $midsql = "select sum(calltime)/count(*) as mid from public.queue_parsed where queue=? and agentid <> 'NONE' and time between ? and ?";
    my $midsth = $this->{dbh}->prepare($midsql);
    eval { $midsth->execute($queue, $sincedatetime, $tilldatetime ); }; 
    if ($@) { 
	$this->{error} = $this->{dbh}->errstr;
	return undef;
    }
    my $ref = $midsth->fetchrow_hashref; 

    my $sql =
 "select sum(calltime)/60||':'||mod(sum(calltime),60) as s,agentid as operator from public.queue_parsed where queue=? and agentid <> 'NONE' and time between ? and ? group by agentid order by agentid";
    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $queue, $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
	
	my @aOfa; 
	my @cdr_keys; 

    while ( my $hash_ref = $sth->fetchrow_hashref ) {
			push @aOfa, [ $hash_ref->{'operator'},$hash_ref->{'s'}+0 ]; 
			push @cdr_keys, $hash_ref;  
    }

	my $template = Template->new( { 
		INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
		INTERPOLATE  => 1, 
		} ) || die "$Template::ERROR\n"; 

	my $jdata = encode_json (\@aOfa);

	my $template_vars = { 
		cdr_keys => \@cdr_keys,
		jdata => $jdata, 
		mid => $ref->{'mid'},
	};  
	$template->process('SumCalltimeByOperatorsInGroup.html', $template_vars) || die $template->error(); 
	
}


1;

__END__

=back

=head1 EXAMPLES


=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut


