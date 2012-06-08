#===============================================================================
#
#         FILE:  outgoingToCustomer.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 05:30:27 EEST
#===============================================================================

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Report::outgoingToCustomer;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template; 

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
		my $phone = $params->{'phone'}; 

    my $sql =
"select calldate,src,dst,split_part(channel,'-',1) as channel, split_part(dstchannel,'-',1) as dstchannel,disposition,billsec from public.cdr where calldate between ? and ? and dst ~ ? order by calldate desc";

    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime, $phone ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    my $hash_ref = $sth->fetchall_hashref('calldate');
    unless ($hash_ref) {
        return 0;
    }

		my $template = Template->new( { 
			INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
			INTERPOLATE  => 1, 
			} ) || die "$Template::ERROR\n"; 

		my @cdr_keys = $this->hashref2arrayofhashref($hash_ref);
		my $template_vars = { 
			cdr_keys => \@cdr_keys,
			pearlpbx_player => sub { return $this->pearlpbx_player(@_); }, 
		};  
		$template->process ('outgoingToCustomer.html', $template_vars) || die $template->error(); 
		
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


