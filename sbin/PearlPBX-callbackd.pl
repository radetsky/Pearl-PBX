#!/usr/bin/env perl 
#===============================================================================
#         FILE:  PearlPBX-callbackd.pl
#        USAGE:  ./PearlPBX-callbackd.pl [ --verbose ]
#  DESCRIPTION:  Find free operator in CallBack* Queues and connect it to context with CallBack to the user instructions 
# REQUIREMENTS:  NewIVR2018 Scenarios
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      CREATED:  2018/11/05
#===============================================================================
use 5.8.0;
use strict;
use warnings;

Callbackd->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => 1,
);

1;

package Callbackd;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::App);
use Getopt::Long qw(:config auto_version auto_help pass_through);
use PearlPBX::CRUD::Queue;
use Data::Dumper;
use PearlPBX::Config -load;
use PearlPBX::Logger;
use NetSDS::Asterisk::EventListener;
use NetSDS::Asterisk::Manager;

sub start {
    my $this = shift;
    $self->SUPER::start();
    $SIG{INT}  = sub { $self->{to_finalize} = 1; };
    $SIG{TERM} = sub { $self->{to_finalize} = 1; };
    $this->queue_status()

}

sub queue_status {
  my $self  = shift;

  my $sent = $self->mgr->sendcommand('Action' => 'QueueStatus');
  unless ( defined($sent) ) {
      return undef;
  }
  my $reply = $self->mgr->receive_answer();
  unless ( defined($reply) ) {
      return undef;
  }

  my $status = $reply->{'Response'};
  unless ( defined($status) ) {
      return undef;
  }
  if ( $status ne 'Success' ) {
      die "Response not success\n";
      return undef;
  }

  my @queue_members;

  my @replies;
  while (1) {
      $reply  = $self->mgr->receive_answer();
      my $event = $reply->{'Event'};
      if ( $event =~ /QueueStatusComplete/i ) {
        last;
      }
      if ( $reply->{'Queue'} ~ 'Callback' ) {
        if ( $event =~ /QueueParams/i ) {
          $self->{queue_params} = $reply;
          $foundQueue = 1;
        } elsif ( $event =~ /QueueMember/i ) {
          push @queue_members, $reply;
        }
      }
  }
  $self->{queue_members} = \@queue_members;

  unless ( defined ( $foundQueue ) ) {
      die "Given queue name not found in QueueStatus response\n";
  }
  return 1;
}

sub _get_today_undone {
    my $this       = shift;
    # Find all undone applications for last 24 hours 
    my $sth = $this->dbh->prepare(
        "select * from callback_list where created between now()-'1 day'::interval and now() and not done");
    eval { $sth->execute(); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchall_hashref('id');
    return $result;
}


sub _cutoff_channel {
    my $this    = shift;
    my $channel = shift;
    my ( $proto, $a ) = split( '/', $channel );
    my ( $peername, $channel_number ) = split( '-', $a );

    return $peername;
}


sub process {
    my $this = shift;

    warn Dumper $this->queue_members; 
    my $event = undef;

    $event = $self->el->_getEvent();
    unless ( defined ( $event ) ) {
        Info("EOF from asterisk manager");
        $self->{to_finalize} = 1;
    }

    if ($event == 0)  {
        sleep(1);
        return;
    }

    unless ( defined ( $event->{'Event'} ) ) {
        Debug("STRANGE EVENT: %s", $event);
        return;
    }

    warn Dumper $event->{'Event'}

}

1;
