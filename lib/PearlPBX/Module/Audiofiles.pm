#===============================================================================
#
#         FILE:  Audiofiles.pm
#
#  DESCRIPTION:  Класс для управления голосовыми файлами 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  30.03.2013 12:19:09 EET
#===============================================================================
=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Module::Audiofiles; 

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Module);
use Data::Dumper; 
use JSON; 
use NetSDS::Util::String;


use version; our $VERSION = "0.01";
our @EXPORT_OK = qw();


#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}


sub getJSON {
	my ($this,$params) = @_; 

	my $sql = "select * from ivr.audiofiles where typeOfMusic=? order by filename,id"; 
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute($params->{'typeOfMusic'}); }; 
    if ( $@ ) {
        print $this->{dbh}->errstr;
        return undef;
    }

    my @audiofiles; 

    while (my $hashref = $sth->fetchrow_hashref ) {
    	$hashref->{'description'} = str_encode($hashref->{'description'} );
    	$hashref->{'filename'}    = str_encode($hashref->{'filename'} ); 
    	push @audiofiles,$hashref; 
    }
    
    my $jdata  = encode_json(\@audiofiles); 
    print $jdata; 
    return 1; 

}

sub del { 
	my ($this, $params) = @_; 

	my $sql = "delete from ivr.audiofiles where id=?";
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute($params->{'id'}); };
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return;
	}
	
	$this->{dbh}->commit; 
	print "OK"; 
	return;

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


