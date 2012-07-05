#===============================================================================
#
#         FILE:  cdrfilter.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  05.07.2012
#===============================================================================

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Report::cdrfilter;

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
    my $tilldatetime  = $this->filldatetime( $params->{'dateTill'}, $params->{'timeTill'} );

    my $sql_cond = $this->fill_direction_sql_condition (0); 

    my $disposition = $this->_sql_cond_disposition ( $params->{'disposition'} );
    my $billsec = $this->_sql_cond_billsec ( $params->{'billsec'} );


    my $sql = "select calldate,src,dst,split_part(channel,'-',1) as channel, 
     split_part(dstchannel,'-',1) as dstchannel,disposition,billsec 
      from public.cdr where calldate between ? and ? 
       and $sql_cond $disposition $billsec order by calldate";

    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    my @cdr_keys; 
    while ( my $hash_ref = $sth->fetchrow_hashref ) {
        push @cdr_keys, $hash_ref; 
    }

	my $template = Template->new( { 
		INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
		INTERPOLATE  => 1, 
	} ) || die "$Template::ERROR\n"; 

	my $template_vars = { 
		cdr_keys => \@cdr_keys,
		pearlpbx_player => sub { return $this->pearlpbx_player(@_); }, 
	};  
	$template->process ('cdrfilter.html', $template_vars) || die $template->error(); 
		
}

sub _sql_cond_disposition { 
    my ( $this, $disposition ) = @_; 

    if ( $disposition =~ /ANSWERED/ ) {
        return 'and disposition=\'ANSWERED\'';
    }
    if ( $disposition =~ /BUSY/ ) { 
        return 'and disposition=\'BUSY\''; 
    }
    if ( $disposition =~ /FAILED/ ) { 
        return 'and disposition=\'FAILED\''; 
    }
    if ( $disposition =~ /NO ANSWER/ ) {
        return 'and disposition=\'NO ANSWER\'';
    }
    return '';

}

sub _sql_cond_billsec { 
    my ($this, $billsec) = @_; 

    if ($billsec == 1) { 
        return 'and billsec between 0 and 30'; 
    }
    if ($billsec == 2) {
        return 'and billsec between 30 and 60'; 
    }
    if ($billsec == 3) {
        return 'and billsec between 60 and 120'; 
    }
    if ($billsec == 4) { 
        return 'and billsec between 120 and 180'; 
    }
    if ($billsec == 5) { 
        return 'and billsec between 180 and 300'; 
    }
    if ($billsec == 6) { 
        return 'and billsec > 300'; 
    }
    return ''; 
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


