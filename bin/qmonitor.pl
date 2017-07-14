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

QMonitor->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/PearlPBX/asterisk-router.conf",
    infinite    => undef
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

sub start {
    my $self = shift;
    # Looking for --qname=queueName
    # We will handle SIGKILL, SIGTERM to return status quo

    my $qname; GetOptions  ('qname=s' => \$qname ); $self->{'qname'} = $qname;
    unless ( defined ( $qname ) ) {
        die "Use --qname=%s to set queue name to monitor\n";
    }

    $self->SUPER::start();

    unless ( $self->queue_status($qname)) {
        die "Something wrong with communication with Asterisk Manager\n";
    }

    $self->pause_lean_agents();
    $self->remember_strategy();
    $self->update_strategy();
    # Goto to process() to listen AMI

}

sub queue_status {
  my $self  = shift;
  my $qname = shift;

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

  my @replies;
  while (1) {
      $reply  = $self->mgr->receive_answer();
      warn Dumper $reply;
      $status = $reply->{'Event'};
      if ( $status =~ /QueueStatusComplete/i ) {
          last;
      }
      push @replies, $reply;
  }

  return 1;

}
sub process {
    my $self  = shift;
    my $event = undef;

    while (1) {
        $event = $self->el->_getEvent();
        unless ( defined ( $event ) ) {
            $self->_exit("EOF from manager");
        }
        if ($event == 0 ) {
            sleep(1);
            next;
        }

        unless ( defined ( $event->{'Event'} ) ) {
            Debug("STRANGE EVENT: %s", $event);
            next;
        }

    }
}

