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

use strict;
use warnings;

use lib "./lib";
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

use base qw(PearlPBX::App);
use Getopt::Long qw(:config auto_version auto_help pass_through);
use Data::Dumper;
use PearlPBX::Config -load;

sub start {
  my $self = shift;

  my $show; GetOptions ('show' => \$show ); $self->{show} = $show;

  $self->SUPER::start();

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

