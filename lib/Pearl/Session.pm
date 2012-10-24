#===============================================================================
#
#         FILE:  Session.pm
#
#  DESCRIPTION:  Служебный модуль для CGI::Session, который помогает достать пользователя 
#                из БД PostgreSQL   
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Radetsky
#      VERSION:  1.0
#      CREATED:  10/23/12 10:55:29 EEST
#===============================================================================
=head1 NAME

Pearl::

=head1 SYNOPSIS

	use Pearl::;

=head1 DESCRIPTION

C<Pearl> module contains superclass all other classes should be inherited from.

=cut

package Pearl::Session;

use 5.8.0;
use strict;
use warnings;

use base qw(CGI::Session::Auth);
use DBI; 

use version; our $VERSION = "0.01";
our @EXPORT_OK = qw();

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = Pearl::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {
	my ( $class, $params ) = @_;
  
	$class = ref($class) if ref($class);
  my $this = $class->SUPER::new($params);
	$this->{dbh} = $params->{dbh} or die "dbh parameter is mandatory";

	return $this;
};

#***********************************************************************
=head1 OBJECT METHODS

=over

Backend specific methods. 
Реализуем механизм "достать пользователя" из нашей базы данных. 

=item B<_login> = Authenticate 
=item B<_loadProfile> = load profile  

=cut

#-----------------------------------------------------------------------
sub _login {
  my $this = shift;
  my ($username, $password) = @_;

  warn "$username,$password"; 

  my $result = 0;
  my $crypted = undef; 

  eval { 
    ($crypted) = $this->{dbh}->selectrow_array("select passwd_hash from auth.sysusers where login=".$this->{dbh}->quote($username));
  }; 

  if ( $@ ) { 
    warn $this->{dbh}->errstr; 
    return undef; 
  }

  if (defined $crypted) {
    $crypted =~ s/\s+//gs;
    if (crypt($password,$crypted) eq $crypted) {
      $this->{userid} = $username;
      $this->_loadProfile($this->{userid});
      return 1;
    }
  }


}

sub _loadProfile {
	my ($this,$userid) = @_;  
  $this->{userid} = $userid;
  $this->{profile}{username} = $userid;
	return 1; 
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


