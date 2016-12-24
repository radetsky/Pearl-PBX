#===============================================================================
#
#         FILE:  SumCallsToExternalExtensions.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 05:30:27 EEST
#     MODIFIED:  24.12.2016 11:10 GMT+2 Merry Christmas !  
#===============================================================================

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Report::SumCallsToExternalExtensions;

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

    my $sql =
"select count(a.dst) as s,a.dst from public.cdr a, routing.directions b where a.calldate between ? and ? and a.disposition = 'ANSWERED' and a.dst ~ b.dr_prefix and length(b.dr_prefix) > 4 and b.dr_prefix !~ E'\\d' and b.dr_prefix !~ E'\\\\[' group by a.dst order by count(dst) desc;"; 

    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
	
		my @aOfa; 
		my @cdr_keys; 

    while ( my $hash_ref = $sth->fetchrow_hashref ) {
			push @aOfa, [ $hash_ref->{'dst'},$hash_ref->{'s'}+0 ]; 
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
		};  
		$template->process('SumCallsToExternalExtensions.html', $template_vars) || die $template->error(); 
		
}

sub hashref2arrayOfArrays {
	my ($this,$hash_ref) = @_;
  my @result; 

  foreach my $hrkey ( keys %$hash_ref ) { 
	  my $sub_hashref = $hash_ref->{$hrkey}; 
		my @sub_array; 
    foreach my $hrsubkey ( keys %$sub_hashref ) { 
			push @sub_array, $sub_hashref->{'dst'}; 
			push @sub_array, $sub_hashref->{'s'}+0; 
		} 
		push @result, [ @sub_array ]; 
  }
	return @result; 
}

sub hashref2arrayofhashref {
  my $this = shift;
  my $hash_ref = shift;
  my @output;

  foreach my $cdr_key (keys %$hash_ref ) {
    my $record = $hash_ref->{$cdr_key};
    push @output, $record;
  }
  return @output;
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


