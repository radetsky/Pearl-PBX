#!/usr/bin/perl
#===============================================================================
#        USAGE:  qmonitor.pl <queueName> <start/stop>
#  DESCRIPTION:  Queue monitoring tool for PearlPBX
#       AUTHOR:  Alex Radetsky <rad@pearlpbx.com>
#      COMPANY:  PearlPBX
#      CREATED:  2017-07-13
#===============================================================================
#
# QMonitor listen AMI events, asks AMI about queue status
# 0. Update strategy to random or other instead of ringall ( constant STRATEGY )
# 1. Pause agents which do not answer for long time (constant LASTCALL in seconds )
# 2. Pause all unavailable agents
# 3. Listen AMI events to find some agent that do not answer for incoming call for N times
# 4. Pause them when counter of unanswered call >= N times (constant UNANSWERED )

use strict;
use warnings;

use lib "./lib";
$ENV{LOG_STDERR} = 1;
QMonitor->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/PearlPBX/asterisk-router.conf",
    infinite    => 1,
);

1;

package QMonitor;

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

use constant STRATEGY => 'random'; # New strategy
use constant LASTCALL => 3600;     # Did not answer for 1 hour ? -> Pause
use constant UNANSWERED => 5;      # Did not answer 5 times ? -> Pause
use constant UNAVAILABLE => 5;     # Status = 5 in QueueStatus means that agent unavailable

sub start {
  my $self = shift;
  # Looking for --qname=queueName
  # We will handle SIGKILL, SIGTERM to return status quo

  my $qname; GetOptions  ('qname=s' => \$qname ); $self->{'qname'} = $qname;
  unless ( defined ( $qname ) ) {
      die "Use --qname=%s to set queue name to monitor\n";
  }

  $self->SUPER::start();

  unless ( $self->queue_status( $qname ) ) {
      die "Something wrong with communication with Asterisk Manager\n";
  }

  $self->pause_lean_agents();
  # $self->remember_strategy();
  # Remember that original params saved in $self->{queue_params};
  $self->update_strategy();
  # Goto to process() to listen AMI

  $SIG{INT}  = sub { $self->{to_finalize} = 1; };
  $SIG{TERM} = sub { $self->{to_finalize} = 1; };

}

sub stop {
  my $self = shift;

  Info("Finishing...");

  #restore strategy
  $self->update_strategy($self->{queue_params}->{'Strategy'});


}

sub queue_status {
  my $self  = shift;
  my $qname = shift;

  my $foundQueue = undef;

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
      warn Dumper $reply;
      my $event = $reply->{'Event'};
      if ( $event =~ /QueueStatusComplete/i ) {
        last;
      }
      if ( $reply->{'Queue'} eq $qname ) {
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

sub pause_lean_agents {
  my $self = shift;

  Info("Pause lean agents...");

  foreach my $member ( @{$self->{queue_members}}) {
    if ($member->{'LastCall'} > LASTCALL ) {
      Infof("Pause lean member %s", $member->{'StateInterface'} );
      $self->pause_member($member->{'StateInterface'}, 'true');
    }
    if ($member->{'Status'} == UNAVAILABLE ) {
      Infof("Pause unavailable member %s", $member->{'StateInterface'});
      $self->pause_member($member->{'StateInterface'}, 'true');
    }
  }
}

sub pause_member {
  my ($self, $member, $status) = @_;

  Infof("Queue pause member %s to status %s", $member, $status);

  my $sent = $self->mgr->sendcommand (
    'Action'    => 'QueuePause',
    'Interface' => $member,
    'Paused'    => $status,
    'Queue'     => $self->{qname},
  );

  unless ( defined($sent) ) {
      return undef;
  }
  my $reply = $self->mgr->receive_answer();
  unless ( defined($reply) ) {
      return undef;
  }

  my $response = $reply->{'Response'};
  unless ( defined ( $response ) ) {
      return undef;
  }
  if ( $response ne 'Success' ) {
      Errf("Response not success: %s", Dumper $reply);
      return undef;
  }
}

sub update_strategy {
  my $self = shift;
  my $strategy = shift // STRATEGY;

  Infof("Update strategy to %s", $strategy);

  my $sql = "update queues set strategy=? where name=?";
  my $sth = $self->dbh->prepare($sql);

  $sth->execute($strategy, $self->{qname});
  $self->queue_reload_parameters();

}

sub queue_reload_parameters {
  my $self = shift;
  Infof("Reload parameters for %s", $self->{qname});
  my $command = 'queue reload parameters '. $self->{qname};

  my $sent = $self->mgr->sendcommand (
    'Action'  => "Command",
    'Command' => $command,
  );

  while (1) {
    my $reply  = $self->mgr->receive_answer();
    warn Dumper $reply;
    my $event = $reply->{'Event'};
    if ( $event =~ /CommandComplete/i ) {
      last;
    }
  }

}

sub incrementFailCounter {
  my $self = shift;
  my $channel = shift;

  my ($interface,$chanId) = split('-', $channel);
  if ( defined ( $self->{failcounters}->{$interface})) {
    $self->{failcounters}->{$interface} = $self->{failcounters}->{$interface} + 1;
  } else {
    $self->{failcounters}->{$interface} = 1;
  }

  Infof("FailCounter for %s set to %d", $interface, $self->{failcounters}->{$interface});

  if ($self->{failcounters}->{$interface} > UNANSWERED ) {
    $self->pause_member($interface, 'true');
    $self->{failcounters}->{$interface} = 0;
  }

}

sub process {
  my $self  = shift;
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

  # Checking DialEnd
  if ( $event->{'Event'} eq 'DialEnd') {
    if ( $event->{'DialStatus'} eq 'NOANSWER') {
      my $destchannel = $event->{'DestChannel'};
      $self->incrementFailCounter($destchannel);

    }

  }
}

