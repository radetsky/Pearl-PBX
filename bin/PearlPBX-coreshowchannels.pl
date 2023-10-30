#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  PearlPBX-coreshowchannels.pl
#
#        USAGE:  ./PearlPBX-coreshowchannels.pl
#
#  DESCRIPTION:  Show current channels in Asterisk. Exactly as asterisk -rx "core show channels".
#                But this script can be run from any user and any directory.
#      OPTIONS:  None
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  1.0
#      CREATED:  27.10.2014
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

CoreShowChannels->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package CoreShowChannels;

use base 'NetSDS::App';
use 5.8.0;
use strict;
use warnings;

use NetSDS::Asterisk::Manager;
use Data::Dumper;

sub process {
  my $this = shift;

  $this->_manager_connect();
  my @replies = $this->_status();
  print($this->_pretty_print(@replies)); 
  $this->_logoff();

  exit(0);
}

sub _pretty_print {
  my $this = shift; 
  my @channels = @_; 

  my $output = "";
  foreach my $channel (@channels) {
    my $name = $channel->{Channel};
    $name =~ s/SIP\/(.*)-.*$/$1/;
    $output .= sprintf("%-20s %-10s %-8s %-10s %-10s %-10s\n",
                       $channel->{ConnectedLineNum} eq '' ? $channel->{CallerIDnum} : $channel->{ConnectedLineNum},
                       $name,
                       $channel->{Application},
                       $channel->{Duration},
                       join("@", $channel->{Extension}, $channel->{Context}),
                       $channel->{ChannelStateDesc},		
		     );
  }
  
  my @strings = split("\n", $output);
  @strings = sort { $a cmp $b } @strings;
  my $sorted_string = join("\n", @strings);
  return $sorted_string . "\n";
}

sub _logoff {
  my $this = shift;

  $this->{manager}->sendcommand(Action => "Logoff");
  my $reply = $this->{manager}->receive_answer();

}

sub _status {
  my $this = shift;
  my $qname = shift;

  my $sent = $this->{manager}->sendcommand('Action' => 'CoreShowChannels');
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
      if ( $status =~ /CoreShowChannelsComplete/i ) {
          last;
      }
      if ( $status =~ /CoreShowChannel/i ) {
	  push @replies, $reply;
      }
  }

  return @replies;

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

