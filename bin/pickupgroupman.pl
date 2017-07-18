#!/usr/bin/perl
#===============================================================================
#        USAGE:  pickupgroupman.pl --show | --set --group --items
#  DESCRIPTION:  Pickup group management tool for PearlPBX
#       AUTHOR:  Alex Radetsky <rad@pearlpbx.com>
#      COMPANY:  PearlPBX
#      CREATED:  2017-07-18
#===============================================================================
#
# Shows and set groups items to pickup feature (*8)
# Uses old NetSDS::App and fucking old code to back compatibility with 1.3.2 :(


use strict;
use warnings;

PickupMan->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => undef,
    has_conf    => 1,
    conf_file   => "/etc/PearlPBX/asterisk-router.conf",
    infinite    => undef,
);

1;

package PickupMan;

use strict;
use warnings;

use base qw(NetSDS::App);
use Getopt::Long qw(:config auto_version auto_help pass_through);
use Data::Dumper;

sub start {
  my $self = shift;

  my $show; GetOptions ('show' => \$show ); $self->{show} = $show;

  $self->SUPER::start();

}
sub start {
    my $this = shift;

    $this->mk_accessors('dbh');
    $this->_db_connect;
}

sub _db_connect {
    my $this = shift;

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->speak("Can't find \"db main->dsn\" in configuration.");
        exit(-1);
    }
    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->speak("Can't find \"db main->login\" in configuraion.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->speak("Can't find \"db main->password\" in configuraion.");
        exit(-1);
    }

    my $dsn    = $this->conf->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->conf->{'db'}->{'main'}->{'login'};
    my $passwd = $this->conf->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->dbh or !$this->dbh->ping ) {
        $this->dbh(
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }
    if ( $this->{verbose} ) {
        $this->agi->verbose( "Database connected.", 3 );
    }
    return 1;
}

sub show_groups {
    my $self = shift;

    my $sql = "select name,pickupgroup from sip_peers where pickupgroup != '' order by pickupgroup,name";
    my $ary_ref = $self->dbh->selectall_arrayref($sql);

    while ( my ($name, $grp ) = each @{$ary_ref} ) {
        printf("%10s %10s\n", $name, $grp);
    }

}

sub process {
  my $self  = shift;

  if ( defined ( $self->{show} ) ) {
    $self->show_groups();
    return;
  }
}

