#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-gui-passwd.pl
#
#        USAGE:  ./PearlPBX-gui-passwd.pl 
#
#  DESCRIPTION:  passwd tool for PearlPBX auth.sysusers table 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  10/23/12 19:06:22 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Config::General; 
use DBI; 

my $username = $ARGV[0];
my $password = $ARGV[1];

unless ( defined ( $username ) and defined ( $password ) )  {
	die "Usage: $0 <username> <password>\n"; 
}

my $conf = "/etc/PearlPBX/asterisk-router.conf"; 

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
    die "Can't read config!\n";
  }

  my %cf_hash = $config->getall or ();
  $conf = \%cf_hash;

  	unless ( defined( $conf->{'db'}->{'main'}->{'dsn'} ) ) {
        die "Can't find \"db main->dsn\" in configuration.\n";
    }

    unless ( defined( $conf->{'db'}->{'main'}->{'login'} ) ) {
        die "Can't find \"db main->login\" in configuraion.\n";
    }

    unless ( defined( $conf->{'db'}->{'main'}->{'password'} ) ) {
        die "Can't find \"db main->password\" in configuraion.\n";
    }

    my $dsn    = $conf->{'db'}->{'main'}->{'dsn'};
    my $user   = $conf->{'db'}->{'main'}->{'login'};
    my $passwd = $conf->{'db'}->{'main'}->{'password'};

    my $dbh = DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1, AutoCommit => 0 } );
   
    unless ( defined ( $dbh ))  { die "Cant connect to DBMS!\n"; }
 
 	my $sql = "select login from auth.sysusers where login=?"; 
 	my $sql2 = "update auth.sysusers set passwd_hash=? where login=?"; 
 	my $sql3 = "insert into auth.sysusers (login,passwd_hash) values (?,?)"; 

 	my $sth = $dbh->prepare($sql); 
 	$sth->execute($username); 
 	my $res = $sth->fetchrow_hashref; 
 	my $row = $res->{'login'}; 

 	unless ( defined ($row)) { 
 		$sth = $dbh->prepare($sql3); 
 		$sth->execute($username,crypt($password,$username));
 		$dbh->commit; 
 		print "Username and password was added successful.\n"; 
 		exit(0);
 	}

 	$sth = $dbh->prepare($sql2); 
 	$sth->execute(crypt($password,$username), $username); 
 	$dbh->commit; 
 	print "Password for user $username was replaced successful.\n"; 
 	exit(0); 

1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-gui-passwd.pl

=head1 SYNOPSIS

PearlPBX-gui-passwd.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

