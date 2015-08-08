#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  deluser.pl
#
#        USAGE:  ./deluser.pl 
#
#  DESCRIPTION:  Delete PearlPBX user  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  09.07.2015 17:52:49 EEST
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

   my $hash_ref = $dbh->selectrow_hashref("select id from sip_peers where name='".$ARGV[0]."'");
   unless ( defined ( $hash_ref->{'id'} ) ) {
		die "User " . $ARGV[0] . " not found."; 
   } 
	my $sip_id = $hash_ref->{'id'}; 
  $dbh->do("delete from routing.permissions where peer_id=$sip_id"); 
  $dbh->do("delete from integration.workplaces where sip_id=$sip_id"); 
  $dbh->do("delete from public.sip_peers where id=$sip_id"); 

  $dbh->commit;
  print "User was deleted successful.\n";
  exit(0);

1;

1;
#===============================================================================

__END__

=head1 NAME

deluser.pl

=head1 SYNOPSIS

deluser.pl

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

