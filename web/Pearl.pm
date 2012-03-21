#===============================================================================
#
#         FILE:  Pearl.pm
#
#  DESCRIPTION:  Base class for Pearl Engine.
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  21.03.2012 00:26:21 EET
#===============================================================================
=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use Pearl::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package Pearl;

use 5.8.0;
use strict;
use warnings;

use CGI; 

use version; our $VERSION = "1.0";
our @EXPORT_OK = qw();

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {

	my $this = {};
	$this->{cgi} = CGI->new; 
	bless $this;
	return $this;

};

#***********************************************************************
=head1 OBJECT METHODS

=over

=item B<user(...)> - object method

=cut

#-----------------------------------------------------------------------

sub parseDate {

	my $this = shift; 
	my $param = shift; 

	return undef unless ( $param ); 
	
  unless ( $param =~ /^(\d{4})-(\d{2})-(\d{2})$/ ) {
		return undef; 
	}

	return 1; 
};

sub parseTime { 

	my $this = shift; 
	my $param = shift; 

	return undef unless ( $param ); 
	
	unless ( $param =~ /^(\d{2}):(\d{2})$/ ) { 
		return undef; 
	}

	return 1;  
}

sub parsePhone { 

	my $this = shift; 
	my $param = shift; 

	return undef unless ( $param ); 
	
	unless ( $param =~ /^(\d{3,15})$/ ) { 
		return undef; 
	}

	return 1;  
}


sub htmlError { 
  my $this = shift; 
	my $str = shift; 

	$this->htmlHeader; 
	my $out = "<font color=#ff0000>".$str."</font>";
	print $out; 
};

sub htmlHeader {
	my $this = shift; 
	print $this->{cgi}->header( -type => 'text/html', 
		                    			-charset => 'utf-8' );
}; 

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


