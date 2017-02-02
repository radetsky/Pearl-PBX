#!/usr/bin/env perl 
#===============================================================================
#         FILE:  PearlPBX-rocket-dialer.pl
#
#        USAGE:  ./PearlPBX-rocket-dialer.pl --src <Telephone> --dst <Telephone> --taskName AsteriskContext 
#                --parameters VAR1=VAL1&VAR2=VAL2&VAR3=VAL3 [ --notifyURL http://google.com/notify?status=%status% ] 
#
#  DESCRIPTION:  Automatically dials to <Telephone> using PearlPBX routing information. 
#                Using N tries (see config). Sends notifyURL when status is OK, FAILED, BUSY.
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX, Sirena-Apps.com
#      VERSION:  1.0
#      CREATED:  2017-01-25 (Saint Tatyana's day)
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use lib './perl-NetSDS-Asterisk/NetSDS-Asterisk/lib';

RocketDialer->run(
    daemon      => undef,
    verbose     => 1,
    use_pidfile => undef,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef,
);

1;

package RocketDialer; 

use warnings;
use strict;

use base qw(PearlPBX::App); # Already connected to Database, Manager and EventListener
use Getopt::Long qw(:config auto_version auto_help pass_through);
use Data::Dumper; 

use constant MAX_TRIES    => 5; 
use constant CALL_TIMEOUT => 60*1000;
use constant BUSY_TIMEOUT => 30;  
use constant REASON => { 
        '0' => 'CONGESTION',
        '1' => 'HANGUP',
        '2' => 'LRINGING',
        '3' => 'RINGING',
        '4' => 'ANSWERED',
        '5' => 'BUSY',
        '6' => 'OFFHOOK1',
        '7' => 'OFFHOOK2',
        '8' => 'NO ANSWER',
    };

sub start {
    my $this = shift; 

    $this->SUPER::start();

    my $src = undef; GetOptions ('src=s' => \$src ); $this->{src} = $src;
    unless ( defined ( $src ) ) {
        $this->_exit("Use --src to set source user to dial. For example, --src=200 ");
    }

    my $dst = undef; GetOptions ('dst=s' => \$dst ); $this->{dst} = $dst; 
    unless ( defined ( $dst ) ) { 
        $this->_exit("Use --dst parameter to give the target to dial.");
    }
   
    my $taskName = undef; GetOptions ('taskName=s' => \$taskName); $this->{taskName} = $taskName;
    unless ( defined ( $taskName ) ) {
       $this->_exit("No task name given. ;( "); 
    } 
}

sub process {
	my $this = shift; 

	$this->speak("Telephone: ".$this->{dst}. " Task: ". $this->{taskName}); 

	my $parked = $this->find_parked_call($this->{dst}); 
	if ( defined ( $parked ) ) {
		$this->unpark2context( $parked->{ParkeeChannel} );
        $this->notifyURL('OK_PARKED'); 
        return 1; 
    } 
	$this->speak("Not found in ParkedCalls. Search for dial route.");
    $this->set_callerid(); # Setting CallerID in this->{callerid}
    my $try = 1;
    my $prio = 1; 
    my $status = 'INIT'; 
    while ( $try <= MAX_TRIES ) {
        last unless $this->route_call( $prio, $try );
        $status = $this->originate();
        my $log = "Try: $try, Step: $prio, Status: $status"; 
        $this->log('info', $log); 
        $this->speak($log); 
        if ( ( $status =~ /CONGESTION/ ) || ( $status =~ /HANGUP/ ) ) {
            if ( $this->{dst_type} eq 'trunk') {
                $prio += 1; 
            }
        }

        if ( $status =~ /^ANSWER/ ) {
            last; #OK
        }
        if ( ( $status =~ /^BUSY/ ) || ( $status =~ /^NO ANSWER/ ) ) {
            $this->sleep(BUSY_TIMEOUT);
        }

        $try += 1; 

    }
    $this->notifyURL($status);
    return 1; 
}

sub notifyURL {
    my ($this, $status) = @_;
    $this->speak('NotifyURL: XXX -> Status = ' . $status); 
    
}

sub originate {
    my $this = shift; 

    $this->mgr->sendcommand ( 
        Action   => 'Originate',
        ActionID => $this->{dst},
        Channel  => $this->{channel},
        Context  => $this->{taskName},
        Exten    => '0',
        Priority => '1',
        Timeout  => CALL_TIMEOUT,
        CallerID => $this->{callerid},
        Account  => $this->{taskName},
        Async    => 'true',
    ); 

    my $reply = 0; 
    while ( !$reply ) {
        $reply = $this->mgr->receive_answer();
    }
    #warn Dumper $reply; 
    my $response = $reply->{Response}; 
    my $message  = $reply->{Message}; 
    $this->speak($response . " : " . $message ); 
    if ($response =~ /ERROR/i) {
        return 'ERROR';
    }

    while (1) {
        my $event = $this->el->_getEvent();
        if ( (! defined ($event)) || $event eq '0' ) { sleep 1; next; }

        if ( defined ( $event->{'Event'} ) ) {
            if ( $event->{'Event'} =~ /OriginateResponse/i ) {
                if ($event->{'ActionID'} eq $this->{dst} ) {
                    #warn Dumper $event; 
                    if ( defined ($event->{'Response'} ) ) {
                        if ( $event->{'Response'} =~ /Success/i ) {
                            return 'ANSWERED';
                        } else {
                            return REASON->{$event->{'Reason'} };
                        }
                    }
                } else {
                    #warn Dumper $event->{'Event'}, $event->{'ActionID'}; 
                }
            } else {
                #warn Dumper $event->{'Event'}; 
            }
        }
        # TODO: засечь время и по достижению (CALL_TIMEOUT + CALL_TIMEOUT) вернуть ошибку TIMEOUT_PERL
    }

    return $response;
}

sub sleep {
    my ($this, $timeout) = @_; 
    $this->speak("Sleeping for $timeout seconds..."); 
    $this->log('info', 'Sleeping for ' . $timeout . ' seconds.'); 
    sleep($timeout); 
}

sub unpark2context {
	my $this = shift;
	my $channel = shift; 
	my $context = $this->{taskName}; 

    # Try to connect with context taskName 

	$this->mgr->sendcommand (
		Action   => 'Redirect',
		Channel  => $channel, 
		Context  => $context, 
		Exten    => '0',
		Priority => '1',
	);

	my $reply = $this->mgr->receive_answer();
	# warn Dumper $reply;


}


=item B<get_parked_calls>

Get the array of parked calls.

=cut

sub get_parked_calls {
    my $this = shift;

    my $sent = $this->mgr->sendcommand( 'Action' => 'ParkedCalls' );

    unless ( defined($sent) ) {
        $this->seterror("Can't send command ParkedCalls");
        return undef;
    }

    my $reply = $this->mgr->receive_answer();

    unless ( defined ( $reply ) ) {
        $this->seterror("Can't receive answer");
        return undef;
    }

    my $status = $reply->{'Response'};

    unless ( defined($status) ) {
        $this->mgr->seterror("Can't get status");
        return undef;
    }

    if ( $status ne "Success" ) {
        $this->mgr->seterror("Status not success");
        return undef;
    }
    my @replies;
    while (1) {
        $reply  = $this->mgr->receive_answer();
        # warn Dumper $reply;
        $status = $reply->{'Event'};
        if ( $status eq 'ParkedCallsComplete' ) {
            last;
        }
        push @replies, $reply;
    }
    return \@replies;
} ## end sub get_parked_calls

=item B<find_parked_call(channel)>

 Find the parked call by channel name

=cut

sub find_parked_call {
    my $this              = shift;
    my $parkeeCallerIDNum = shift;

    my $parkedcalls = $this->get_parked_calls();
    unless ( defined ( $parkedcalls ) ) { 
        $this->speak($this->mgr->geterror()); 
        return undef; 
    }

    my $i = 0;
    while ( $i <= @{$parkedcalls} ) {
        my $parkedcall = $parkedcalls->[ $i++ ];

        next unless defined $parkedcall->{'ParkeeCallerIDNum'}; 
        if ( $parkedcall->{'ParkeeCallerIDNum'} eq $parkeeCallerIDNum ) {
            return $parkedcall;
        }
    }
    return undef;
} ## end sub find_parked_call

sub set_callerid {
    my $this = shift;

    my $sth = $this->dbh->prepare("select get_callerid from routing.get_callerid (?,?)");
    eval { my $rv = $sth->execute($this->{src}, $this->{dst}); };
    if ($@) {
        $this->_exit("Can't get caller_id information: " . $this->dbh->errstr)
    }
    my $result = $sth->fetchrow_hashref;
    $this->{callerid} = $result->{'get_callerid'} // ''; 
}

sub route_call {
    my ( $this, $step, $try ) = @_; 

    my $sth = $this->dbh->prepare(  "select * from routing.get_dial_route4 (?,?,?)" );
    eval { my $rv = $sth->execute( $this->{src}, $this->{dst}, $step ); };
    if ($@) {
        # ERROR: NO ROUTE 
        return undef; 
    }
    my $result = $sth->fetchrow_hashref;
    $this->{dst_str}  = $result->{'dst_str'};
    $this->{dst_type} = $result->{'dst_type'};
    $this->speak("dst_str=".$this->{dst_str}.",dst_type=".$this->{dst_type}.",step=$step, try=$try");
    $this->{channel} = "SIP/" . $this->{dst_str} . "/" . $this->{dst}; 
    return 1; 

}


