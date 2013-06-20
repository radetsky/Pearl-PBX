#===============================================================================
#
#         FILE:  CityComSumLost.pm
#
#  DESCRIPTION:  Модуль для Ситикома.  Количество пропущенных звонков.  
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

package PearlPBX::Report::CityComSumLost;

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
        "select count(queuename) as s,queuename from queue_log 
            where event in ('ABANDON','EXITWITHKEY','EXITWITHTIMEOUT') 
                and time between ? and ? group by queuename order by count(queuename) desc"; 
  
    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    
    my @aOfa; 
  
    while ( my $hash_ref = $sth->fetchrow_hashref ) {
            push @aOfa, [ $hash_ref->{'queuename'},$hash_ref->{'s'}+0 ]; 
    }

    print encode_json (\@aOfa);
        
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


