#===============================================================================
#
#         FILE:  SumOutgoingByOperatorsInGroup.pm
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

package PearlPBX::Report::SumOutgoingByOperatorsInGroup;

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

    my $sql =
"select count(split_part(a.channel,'-',1)) as s, split_part(a.channel,'-',1) as operator from public.cdr a, public.queue_members b 
 	where calldate between ? and ? and b.interface = split_part(a.channel,'-',1) 
 		and b.queue_name=? and dst ~ E'^\\\\d\\\\d\\\\d' 
 			group by split_part(a.channel,'-',1) order by count(src) desc; ";
    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime, $queue ); };
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
		};  
		$template->process('SumOutgoingByOperatorsInGroup.html', $template_vars) || die $template->error(); 
		
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


