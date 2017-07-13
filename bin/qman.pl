#!/usr/bin/perl
#===============================================================================
#        USAGE:  qman.pl <command> [<parameters>]
#  DESCRIPTION:  Queue management from command line for PearlPBX
#       AUTHOR:  Alex Radetsky <rad@pearlpbx.com>
#      COMPANY:  PearlPBX
#      CREATED:  2017-07-13
#===============================================================================

use strict;
use warnings;

use lib './lib';

QMan->run (
	daemon      => undef,
    verbose     => 1,
    use_pidfile => undef,
    has_conf    => 1,
    conf_file   => "/etc/PearlPBX/asterisk-router.conf",
    infinite    => undef
);

1;

package QMan;

use strict;
use warnings;

use base qw(PearlPBX::App);
use Getopt::Long qw(:config auto_version auto_help pass_through);
use PearlPBX::CRUD::Queue;
use Data::Dumper;

use constant SHOW => 'show';
use constant UPDATE => 'update';

sub start {
	my $self = shift;
	my $cmd; GetOptions  ('cmd=s' => \$cmd ); $self->{'cmd'} = $cmd;
    my $name; GetOptions ('name=s' => \$name); $self->{'name'} = $name;
}

sub process {
    my $self = shift;
    my $cmd = $self->{'cmd'};
    unless ( defined ( $cmd ) ) {
        print("Use --cmd=<show|update>\n");
        return;
    }
    if ( ( $cmd ne SHOW ) && ( $cmd ne UPDATE ) )  {
        print("Use --cmd=<show|update>\n");
        return;
    }

    if ( $cmd eq UPDATE ) {
        $self->update();
    } else {
        $self->show();
    }
}

sub show {
    my $self = shift;
    my $crud = PearlPBX::CRUD::Queue->new();
    unless ( defined ( $self->{name} ) ) {
        #show all queues
        my $result = $crud->read();
        warn Dumper $result;
    } else {
        #show one named queue

    }

}
