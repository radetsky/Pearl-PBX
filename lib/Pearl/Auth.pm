#===============================================================================
#
#         FILE:  Auth.pm
#
#  DESCRIPTION:  методы для авторизации и аунтентификации пользователей 
#                для сайтов на основе Pearl Engine 1.0 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  10/23/12 11:54:52 EEST
#===============================================================================
=head1 NAME

Pearl::

=head1 SYNOPSIS

	use Pearl::;

=head1 DESCRIPTION

C<Pearl> module содержит методы для авторизации и аунтентификации пользователей 
для сайтов на основе Pearl Engine 1.0 

=cut

package Pearl::Auth;

use 5.8.0;
use strict;
use warnings;

use DBI;
use Config::General; 
use CGI::Session; 
use Pearl::Session; 

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

  my $conf = $params->{'config'}; 

  unless ( defined ( $conf ) ) {
     $conf = '/etc/PearlPBX/asterisk-router.conf';
  }

  my $config = Config::General->new (
    -ConfigFile        => $conf,
    -AllowMultiOptions => 'yes',
    -UseApacheInclude  => 'yes',
    -InterPolateVars   => 'yes',
    -ConfigPath        => [ $ENV{PEARL_CONF_DIR}, '/etc/PearlPBX' ],
    -IncludeRelative   => 'yes',
    -IncludeGlob       => 'yes',
    -UTF8              => 'yes',
  );

  unless ( ref $config ) {
    return undef;
  } 

  my %cf_hash = $config->getall or ();

  my $this = {}; 

  $this->{conf} = \%cf_hash;

  $this->{dbh} = undef;     # DB handler 
  $this->{error} = undef;   # Error description string  
  $this->{auth} = undef;    # Pearl::Session   

  bless ($this, $class); 
	return $this;

};

#***********************************************************************
=head1 OBJECT METHODS

=over

=item B<db_connect(...)> - соединяется с базой данных. 
Возвращает undef в случае неуспеха или true если ОК.
DBH хранит в this->{dbh};  

=cut

#-----------------------------------------------------------------------

sub db_connect {
  my $this = shift; 
  
    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->{error} = "Can't find \"db main->dsn\" in configuration.";
        return undef;  
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->{error} = "Can't find \"db main->login\" in configuraion.";
        return undef;
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->{error} = "Can't find \"db main->password\" in configuraion.";
        return undef;
    }

    my $dsn    = $this->{conf}->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->{conf}->{'db'}->{'main'}->{'login'};
    my $passwd = $this->{conf}->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->{dbh} or !$this->{dbh}->ping ) {
        $this->{dbh} = 
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1, AutoCommit => 0 } );
    }

    if ( !$this->{dbh} ) {
        $this->{error} = "Cant connect to DBMS!";
        return undef;
    }

    return 1;
};

sub login {
  my ( $this, $cgi, $nofail ) = @_;

  my $session = new CGI::Session (undef, $cgi, {Directory=>'/tmp'});
  
  $this->{auth} = new Pearl::Session({ CGI => $cgi, Session => $session, dbh => $this->{dbh} });
  $this->{auth}->logout(); 
  $this->{auth}->authenticate();

  if ($this->{auth}->loggedIn) {
    return $this->{auth}->profile('username');
  } else {
    warn 'access denied while authentication.'; 
    return undef if defined $nofail;
    print $cgi->header(-type=>'text/html',-charset=>'utf-8');
    print "ACCESS DENIED\n";
    exit;
  }
}

sub logout {
  my $this = shift;
  return 0 unless defined $this->{auth}; # Если не аутентифицировали, закрывать нечего
  $this->{auth}->logout();
}

=item $cookie = cookie();

Возвращает Cookie для удержания сессии в формате CGI::Cookie
Годится для print $cgi->header(-cookie=>$cookie)

=cut

sub cookie {
  my $this = shift;
  return undef unless defined $this->{auth};
  return $this->{auth}->sessionCookie();
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


