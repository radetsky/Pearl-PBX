package PearlPBX::DB;

use warnings;
use strict;

use DBI;
use Config::General;
use Exporter; 
use PearlPBX::Config qw(conf); 

our @EXPORT_OK = qw(
	pearlpbx_db
);

sub import {
    splice @_, 0, 1, __PACKAGE__ unless $_[0] eq __PACKAGE__;
    goto &Exporter::import;
}

my $this;


sub new {
    my $class = shift;
    my $this = {}; 

    $this->{conf} = conf(); 
    $this = bless $this, $class;
    $this->_connect(); 
    return $this; 
}

sub dbh {
    return $this->{dbh};  
}

sub _connect {
  my $this = shift; 
  my $dsn  = $this->{conf}->{db}->{main}->{dsn}      // 'dsn dbi:Pg:dbname=asterisk;host=127.0.0.1';
  my $user = $this->{conf}->{db}->{main}->{login}    // 'asterisk';
  my $pass = $this->{conf}->{db}->{main}->{password} // 'supersecret';

  if ( !$this->{dbh} or !$this->{dbh}->ping ) {
    $this->{dbh} = DBI->connect_cached ( $dsn, $user, $pass,
        { RaiseError => 1, AutoCommit => 1 } );
  }
  if ( !$this->{dbh} ) {
    die "Can't connect to database: " . $dsn . "\n";
  }

}

1;

