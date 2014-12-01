#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-ChannelCheck.pl
#
#        USAGE:  ./PearlPBX-ChannelCheck.pl 
#
#  DESCRIPTION:  Проверяет список активных каналов на принадлежность к пиру по маске 
#                и принадлежность набранного номера к одному из операторов связи по маске префиксов 
#                Сделано изначально для БКМ, у которых есть 9 каналов на одного пира, но надо ограничить 
#                количество исходящих звонков на МТС, КС и Лайф по одному.  
#      OPTIONS:  Маска канала (eurotel), номер по которому звонит абонент (0504139380)
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  1.0
#      CREATED:  27.10.2014 
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

ChannelCheck->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1, 
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;
 
package ChannelCheck; 

use base 'PearlPBX::IVR'; 
use 5.8.0;
use strict;
use warnings;

use NetSDS::Asterisk::Manager;
use Data::Dumper;

use constant providers => { 
  MTS  => '^(050|095|099|066|38050|38066|38095|38099)',
  KS   => '^(067|068|096|097|099|38067|38068|38096|38097|38098)',
  Life => '^(093|063|38063|38093)'
}; 

sub process { 
  my $this = shift; 

  unless ( defined ( $ARGV[0] ) or defined ( $ARGV[1]) ) { 
	  $this->agi->verbose("Usage: ".$this->{name}." <channel mask> <msisdn> ", 3); 
	  exit(-1);
  }

  $this->agi->set_variable ('BUSYTRUNK','0'); 
  my $group = $this->_is_need_be_checked($ARGV[1]); 
  $this->_manager_connect(); 
  $this->_busytrunk( $ARGV[0], $ARGV[1], $group, $this->_status() ); 
  $this->_logoff(); 

  exit(0);
}

sub _is_need_be_checked { 
  my ($this, $msisdn) = @_; 
  my $prov = providers; 

  foreach my $group ( keys %{ $prov }) { 
    if ($msisdn =~ providers->{$group}) {
#      warn "Group = $group\n"; 
      return $group; 
    }
  }

  exit(0); 
}

sub _logoff { 
  my $this = shift; 

  $this->{manager}->sendcommand(Action => "Logoff"); 
  my $reply = $this->{manager}->receive_answer();

}

sub _status { 
  my $this = shift; 
  my $qname = shift; 

  my $sent = $this->{manager}->sendcommand('Action' => 'Status'); 
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
      if ( $status =~ /StatusComplete/i ) {
          last;
      }
      push @replies, $reply;
  }

  return @replies; 

}

sub _busytrunk { 
  my ($this, $channelmask, $msisdn, $provider, @events) = @_; 

  my $busytrunk = 0; 

#  warn Dumper \@events; 

  foreach my $e (@events) { 
    if ($e->{'Event'} eq 'Status') { 
      if ($e->{'Channel'} =~ /$channelmask/ ) { 
        if ($e->{'Extension'} =~ providers->{$provider}) { 
          $this->agi->set_variable("BUSYTRUNK","1"); 
          return 1; 
        }
      } 
    }  
  }
  return undef; 
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

