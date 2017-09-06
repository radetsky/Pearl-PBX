#!/usr/bin/env perl

use warnings;
use strict;

use AnyEvent;
use AnyEvent::Socket qw/tcp_server tcp_connect/;
use AnyEvent::Handle;
use Data::Dumper;

use NetSDS::Asterisk::Manager;
use NetSDS::Util::DateTime;  
use version; our $VERSION = "1.0";

use constant {
  AMI_USERNAME => 'web-call',
  AMI_SECRET   => 'sferA19869',
  TN_SERVER    => '192.168.88.3',
  TN_PORT      => '6010',
  TN_TRIES     => 5,
};

my $context = {
  'Машина по адресу.Пожалуйста, выходите' => 'pleaseExit',
};

my $tcp_server = tcp_server(
    '0.0.0.0',
    '6301',
    sub {
        my ( $socket, $fromhost, $fromport ) = @_;
        warn "Accept connection from $fromhost:$fromport with socket: $socket";

        my $data;
        $data = '';
        my $read_watcher;
        $read_watcher = AnyEvent->io(
            fh   => $socket,
            poll => "r",
            cb   => sub {
                my $read = sysread( $socket, $data, 1024 );
                if ( $read <= 0 ) {
                    undef $read_watcher;
                    warn "Closing connection to $fromhost:$fromport";
                    AnyEvent->condvar->send;
                }
                else {
                    # here we handle the data
                    # warn Dumper $data;
                    handleIncomingMessage($data);
                }
            }
        );

    },
    sub {
        my ( $socket, $thishost, $thisport ) = @_;

        warn "Bound to $thishost:$thisport";

    }
);

AnyEvent->condvar->recv;

sub handleIncomingMessage {
    my $incoming = shift;
    my $message = command_reply_to_hash($incoming);

    my %handleFunctions;

	$handleFunctions{'SayText'} = sub {
	  my $message = shift;
	  warn "SayText " . Dumper $message; 
	  if ( !defined ($message->{'NumberToCall'}) || !defined ($message->{'Guid'}) || !defined ($message->{'TextToSay'})) {
	    warn "Message SayText validation error. Something missing.\n";
	    return undef;
	  }
	  my $dst  = $message->{'NumberToCall'};
	  my $guid = $message->{'Guid'};
	  my $msg  = $message->{'TextToSay'};

	  my $tries = 0; 

	  while ( $tries < TN_TRIES ) { 

		  my $mgr = NetSDS::Asterisk::Manager->new(
		    host => '127.0.0.1',
		    port => '5038',
		    username => AMI_USERNAME,
		    secret => AMI_SECRET,
		    events => 'Off',
		  );
		  my $connected = $mgr->connect;
		  unless ( defined ( $connected) ) {
		    warn "Can not connect to Asterisk Manager\n";
		    return undef;
		  }

		  my $sent = $mgr->sendcommand(
		    Action   => 'Originate',
		    Async    => 'Off',
		    Channel  => sprintf("Local/%s\@from-sip", $dst),
		    Exten    => $dst,
		    Timeout  => 30000,
		    Context  => $context->{$msg},
		    Priority => 1, 
		    ActionID => $guid
		  );

		  my $response = $mgr->receive_answer();
		  while ( $response eq '0' ) {	
		     $response = $mgr->receive_answer();
		  }
		
		  #Вернуть статус согласно документации 

		  warn Dumper $response; 
		  my $status = $response->{'Response'} eq 'Error' ? 'Busy' : 'Done'; 
		  my $timeChanged = date_now();

		  tcp_connect TN_SERVER,TN_PORT, sub {
		      my ($fh) = @_; 
		      unless ( defined ( $fh) ) { 
			warn "Can not connect to TN_SERVER"; 
			return undef; 
		      }
		      my $text = sprintf("Message: SayTextStatus\r\nGuid: %s\r\nStatus: %s\r\nStatusChangedTime: %s\r\n\r\n", $guid, $status, $timeChanged);
		      syswrite $fh, $text;
		  };

	          $tries += 1; 
		  if ( $status eq 'Done' ) { 
			last; 
		  }
          }
	 
	  return 1; 

	};

    # warn Dumper $message;
    if ( defined ( $message)  && defined ( $message->{'Message'} ) ) {
       $handleFunctions{$message->{'Message'}}($message); # Handle it
    }
}

sub command_reply_to_hash {
    my ($reply) = @_;
    my ( $key, $val );

    my $answer;
    my (@rows) = split( /\n/, $reply );

    foreach my $row (@rows) {
        if ($row) {
            if ( $row =~ m/\n/ ) {
                my @arr = split( m/\n/, $row );
                $arr[$#arr] =~ s/--END COMMAND--$//;
                $answer->{'raw'} = @arr;
            }
            else {
                ( $key, $val ) = split( ':', $row );
		if ( defined ( $val )) { 
                    $key            = trim($key);
                    $val            = trim($val);
                    $answer->{$key} = $val;
		}
            }
        }
    }
    return $answer;
} ## end sub command_reply_to_hash

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

1;
