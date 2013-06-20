#===============================================================================
#
#         FILE:  CityComSumSent.pm
#
#  DESCRIPTION:  Модуль для Ситикома.  Количество исходящих звонков.  

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

package PearlPBX::Report::CityComSumSent;

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

 	my $sql_cdr = 
    "select count(split_part(channel,'-',1)),split_part(channel,'-',1) as operator, disposition 
        from public.cdr where calldate between ? and ? 
            and channel ~ E'^SIP/2\\\\d\\\\d-' 
                group by split_part(channel,'-',1), disposition  
                order by split_part(channel,'-',1);";


    my $sth_cdr = $this->{dbh}->prepare($sql_cdr);
    eval { $sth_cdr->execute ( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    
    my $data_cdr = $sth_cdr->fetchall_hashref ('operator');

	my $data_cdr2; 
    foreach my $key ( keys %{$data_cdr} ) { 
        my ($proto, $newkey) = split ('/', $key ); 
        $data_cdr2->{$newkey} = $data_cdr->{$key}; 
    }

 #   print Dumper ($data_cdr2); 

    my @result; 
    
    # Join it. 
    foreach my $key ( sort keys %{$data_cdr2} ) { 
        my $agent = $key; 
        my $calls = $data_cdr2->{$key}->{'count'}; 
        my $disposition = $data_cdr2->{$key}->{'disposition'}; 

        my $record->{'disposition'} = $disposition; 
        $record->{'calls'} = $calls; 
        $record->{'agent'} = $agent; 

        push @result,$record; 

    }

    my $json = encode_json(\@result); 
    print $json; 

	return 1; 
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


