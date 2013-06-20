#===============================================================================
#
#         FILE:  CityComSumLost.pm
#
#  DESCRIPTION:  Модуль для Ситикома. Суммы и средние разговоры.   
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

package PearlPBX::Report::CityComTalks;

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

    # Исходящие 
    my $sql =
        "select sum(billsec) as sum, count(calldate) as count, avg (billsec) as avg, 
         split_part(split_part(channel,'-',1),'/',2) as channel from public.cdr 
            where calldate between ? and ?
                and channel ~ E'^SIP/2\\\\d\\\\d-' 
                    group by split_part(channel,'-',1) 
                        order by split_part(channel,'-',1);"; 
  

    # Входящие 
    my $sql2 =
        "select sum(billsec) as sum, count(calldate) as count, avg (billsec) as avg, 
         split_part(split_part(dstchannel,'-',1),'/',2) as channel from public.cdr 
            where calldate between ? and ? 
                and dstchannel ~ E'^SIP/2\\\\d\\\\d-' 
                    group by split_part(dstchannel,'-',1) 
                        order by split_part(dstchannel,'-',1);"; 

    
    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $data_out = $sth->fetchall_hashref('channel'); 


    my $sth2 = $this->{dbh}->prepare($sql2);
    eval { $sth2->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $data_in = $sth2->fetchall_hashref('channel'); 

    my @result; 

    print encode_json ($data_out); 
    print encode_json ($data_in); 


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


