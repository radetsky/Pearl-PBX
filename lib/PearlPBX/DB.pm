package PearlPBX::DB;

use warnings;
use strict;

use DBI;
use Config::General;
use Exporter; 

our @EXPORT_OK = qw(
	pearlpbx_db
);

sub import {
    splice @_, 0, 1, __PACKAGE__ unless $_[0] eq __PACKAGE__;
    goto &Exporter::import;
}

my $this;

sub pearlpbx_db {
    return $this->{dbh};  
}

sub new {
  my ($class, $conf) = @_;

  unless ( $this ) {
    $conf //= "pearlpbx.conf";
    my $config = Config::General->new (
      -ConfigFile        => $conf,
      -AllowMultiOptions => 'yes',
      -UseApacheInclude  => 'yes',
      -InterPolateVars   => 'yes',
      -ConfigPath        => [ $ENV{PEARLPBX_CONFIG_DIR} // '/', '/etc/PearlPBX' ],
      -IncludeRelative   => 'yes',
      -IncludeGlob       => 'yes',
      -UTF8              => 'yes',
    );

    unless ( ref $config ) {
      die "Can't read config.";
    }

    my %cf_hash = $config->getall or ();
    $this = bless {
      conf => \%cf_hash,
      dbh  => undef
    }, $class;

    $this->_connect();

  }

  return $this;
}

sub _connect {
  my $this = shift;

  my $dsn  = $this->{conf}->{db}->{main}->{dsn} // 'dsn dbi:Pg:dbname=asterisk;host=127.0.0.1';
  my $user = $this->{conf}->{db}->{main}->{login} // 'asterisk';
  my $pass = $this->{conf}->{db}->{main}->{password} // 'supersecret';

  if ( !$this->{dbh} or !$this->{dbh}->ping ) {
    $this->{dbh} = DBI->connect_cached ( $dsn, $user, $pass,
                    { RaiseError => 1, AutoCommit => 1 } );

  }
  if ( !$this->{dbh} ) {
    die "Can't connect to database: " . $dsn;
  }

  return 1;

}

1;

