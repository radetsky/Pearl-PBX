#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  makeusers.pl
#
#        USAGE:  ./makeusers.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  11.09.2012 17:00:56 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Config::General; 
use DBI; 

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
 
 	my $sql = "insert into public.sip_peers (name,secret) values (?,?)"; 

 	my $sth = $dbh->prepare($sql); 

	for (my $i = $ARGV[0]+0; $i <= $ARGV[1]+0; $i++) { 
		my $newsecret = `pwgen -c 8 -s`; 
		print $name . " " . $newsecret . "\n"; 
		# $sth->execute($i,$newsecret);
	}

 	$dbh->commit; 
 	print "Ulines was generated  successful.\n"; 
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



1;
#===============================================================================

__END__

=head1 NAME

makeusers.pl

=head1 SYNOPSIS

makeusers.pl

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

