#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  PearlPBX-QueueCheck.pl
#
#        USAGE:  ./PearlPBX-QueueCheck.pl
#
#  DESCRIPTION:  Проверяет указанную очередь и возвращает количество свободных операторов для разговора.
#                Сделано для того, что бы проверить наличие свободных операторов в очереди перед тем, как направить туда звонок.
#                Для скорейшего решения об обработке звонка надо знать сколько там свободных операторов. До вызова Queue(queue).
#
#      OPTIONS:  QueueName
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  1.0
#      CREATED:  27.10.2014
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

QueueCheck->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package QueueCheck;

use base 'PearlPBX::IVR';
use 5.8.0;
use strict;
use warnings;

use NetSDS::Asterisk::Manager;
use Data::Dumper;


sub process {
  my $this = shift;

  unless ( defined ( $ARGV[0] ) ) {
	$this->agi->verbose("Usage: ".$this->{name}." <queuename> ", 3);
	   exit(-1);
  }
  $this->agi->set_variable ('READYTORECEIVE','0');
  $this->agi->set_variable ('QUEUECALLERS','0');
  $this->_manager_connect();
  $this->agi->verbose("Manager connected",3);
  $this->_queue_status($ARGV[0]);
  $this->_logoff();

  exit(0);
}

sub _logoff {
  my $this = shift;

  $this->{manager}->sendcommand(Action => "Logoff");
  my $reply = $this->{manager}->receive_answer();
  unless ( defined($reply) ) {
      return undef;
  }

}

sub _queue_status {
  my $this = shift;
  my $qname = shift;

  my $sent = $this->{manager}->sendcommand('Action' => 'QueueStatus');
  unless ( defined($sent) ) {
      return undef;
  }
  my $reply = $this->{manager}->receive_answer();
  unless ( defined($reply) ) {
      return undef;
  }

  my $status = $reply->{'Response'};
  unless ( defined($status) ) {
      return undef;
  }
  if ( $status ne 'Success' ) {
      $this->agi->verbose('Status: Response not success',3);
      return undef;
  }

  my @replies;
  while (1) {
      $reply  = $this->{manager}->receive_answer();
      $status = $reply->{'Event'};
      if ( $status =~ /QueueStatusComplete/i ) {
          last;
      }
      push @replies, $reply;
  }

  my $ready = 0;
  my $callers = 0;

  foreach my $r (@replies) {
    if ($r->{'Event'} eq 'QueueEntry') {
      if ($r->{'Queue'} eq $qname ) { # Наша очередь
        $callers = $callers + 1;
      }
    }
    if ($r->{'Event'} eq 'QueueMember') {
      if ($r->{'Queue'} eq $qname ) { # Наша очередь
        if ($r->{'Status'} eq '1') {
          if ($r->{'Paused'} eq '0') {
            $ready = $ready + 1;
          }
        }
      }
    }
  }
  $this->agi->set_variable("READYTORECEIVE",$ready);
  $this->agi->set_variable("QUEUECALLERS",$callers);

}

sub _manager_connect {
  my $this = shift;

    # connect
    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->speak("Can't file el->host in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->speak("Can't file el->port in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->speak("Can't file el->username in configuration.");
        exit(-1);
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->speak("Can't file el->secret in configuration.");
        exit(-1);
    }

    my $el_host     = $this->conf->{'el'}->{'host'};
    my $el_port     = $this->conf->{'el'}->{'port'};
    my $el_username = $this->conf->{'el'}->{'username'};
    my $el_secret   = $this->conf->{'el'}->{'secret'};

    my $manager = NetSDS::Asterisk::Manager->new(
        host     => $el_host,
        port     => $el_port,
        username => $el_username,
        secret   => $el_secret,
        events   => 'Off',
    );

    my $connected = $manager->connect;
    unless ( defined($connected) ) {

        $this->agi->verbose("Can't connect to the asterisk manager interface: ".$manager->geterror(), 3);
        $this->log( "warning",
            "Can't connect to the asterisk manager interface: ".$manager->geterror());
        exit(-1);
    }

    $this->{manager} = $manager;
    return 1;
}


1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-calendar.pl

=head1 SYNOPSIS

PearlPBX-calendar.pl

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

