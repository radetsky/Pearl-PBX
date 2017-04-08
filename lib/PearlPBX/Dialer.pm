package PearlPBX::Dialer;

use warnings;
use strict;

use parent qw (Class::Accessor::Class);

use Data::Dumper;
use Proc::Daemon;

use PearlPBX::NotifyHTTP qw(notify_http);
use PearlPBX::Logger;
use PearlPBX::DB;

use PearlPBX::Manager;
use PearlPBX::EventListener;

use constant MAX_TRIES    => 5;
use constant CALL_TIMEOUT => 60*1000;
use constant PEARLPBX_TIMEOUT => 120;
use constant BUSY_TIMEOUT => 30;
use constant REASON => {
        '0' => 'CONGESTION',
        '1' => 'HANGUP',
        '2' => 'LRING',
        '3' => 'RINGING',
        '4' => 'ANSWERED',
        '5' => 'BUSY',
        '6' => 'OFFHOOK1',
        '7' => 'OFFHOOK2',
        '8' => 'NOANSWER',
        '9' => 'TALKINGHERE',
        '10' => 'INIT',
    };

use constant HUMAN_REASON_LIST => qw (
    ANSWERED
    NOANSWER
    FAILED
    BUSY
    TALKINGHERE
);

use constant HUMAN_REASON => { 
    '0' => 'FAILED',
    '1' => 'BUSY',
    '2' => 'NOANSWER',
    '3' => 'NOANSWER',
    '4' => 'ANSWERED',
    '5' => 'BUSY',
    '6' => 'FAILED',
    '7' => 'FAILED',
    '8' => 'NOANSWER',
    '9' => 'TALKINGHERE',
    '10' => 'FAILED',
};
=item

INIT       - невозможно дозвониться из-за проблем в настройке PearlPBX
CONGESTION - невозможно дозвониться по причине занятости или отказа оборудования/провайдера.
HANGUP     - удаленная сторона сбрасывает соедиение
LRING      - локальный КПВ
RINGING    - удаленный КПВ
ANSWERED   - OK, с той стороны подняли трубку
BUSY       - Он и в Африке BUSY
NOANSWER   - Не отвечает.
TALKINGHERE - Уже в локальной станции, в состоянии разговора
OK_PARKED  - перехватили припаркованный звонок

=cut

use constant PARAMS => qw (src dst taskName _notifyURL _fork);

sub new {
	my ($class, $params) = @_;
	my $this;

	# Validate reqired parameters
	foreach my $key ( PARAMS ) {
		if ( $key =~ /^_/ ) {
			$this->{$key} = $params->{$key};
			next; # Optional parameter
		}
		if ( ! defined ( $params->{$key} ) ) {
			die "Required parameter $key not found!\n";
		}
		$this->{$key} = $params->{$key};
	}
	# Fork
    my $pid;
	if ( $this->{_fork} ) {
        CloseLog();
        $SIG{'CHLD'} = 'IGNORE';
        $pid = fork();
        Debugf("PID: %s",$pid);
        if ($pid > 0) {
            return 1;
        }
	}


	$this = bless $this, $class;

    $this->mk_accessors('el');
    $this->mk_accessors('mgr');
    $this->mk_accessors('dbh');

	$this->{db} = PearlPBX::DB->new();
	$this->dbh( $this->{db}->{dbh});
	$this->mgr( PearlPBX::Manager->new());
	$this->el ( PearlPBX::EventListener->new());

	$this->process();
    if ( defined ( $pid ) ) {
        Debugf("My PID is %s", $pid);
        exit 0;
    }

}

sub process {
	my $this = shift;

	Info("Telephone: ".$this->{dst}. " Task: ". $this->{taskName});

	my $parked = $this->find_parked_call($this->{dst});
	if ( defined ( $parked ) ) {
		$this->unpark2context( $parked->{ParkeeChannel} );
        $this->notifyURL('OK_PARKED');
        return 1;
    }
    my $talked = $this->find_active_call($this->{dst});
    if ( defined ( $talked ) ) {
        $this->notifyURL('TALKINGHERE');
        return 1;
    }

	Debug("Not found in PearlPBX. Search for dial route.");

    $this->set_callerid(); # Setting CallerID in this->{callerid}
    my $try = 1;
    my $prio = 1;
    my $status = 'INIT';
    while ( $try <= MAX_TRIES ) {
        last unless $this->route_call( $prio, $try );
        $status = $this->originate();
        Info("Try: $try, Step: $prio, Status: $status");
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
    unless ( defined ( $this->{_notifyURL} ) ) {
        return undef;
    }
    Info('NotifyURL: '. $this->{_notifyURL} . ' -> Status = ' . $status);
    notify_http (
        cont_type => "text/html",
        post_data => $status,
        uri       => $this->{_notifyURL},
    );

}

sub originate {
    my $this = shift;

    #Debugf("Originate CALLERID: %s",$this->{callerid}); 

    $this->mgr->sendcommand (
        Action   => 'Originate',
        ActionID => $this->{dst},
        Channel  => $this->{channel},
        Context  => $this->{taskName},
        Exten    => $this->{dst},
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
    Debug("Response: " . $response . " : " . $message );
    if ($response =~ /ERROR/i) {
        return 'ERROR';
    }

    my $timeIn = time;

    $response = 'PEARLPBX_TIMEOUT';

    while ( PEARLPBX_TIMEOUT > ( time - $timeIn ) ) {
        my $event = $this->el->_getEvent();
        #Debugf("Event: %s",$event); 
        unless ( defined ( $event ) ) {
            $this->_exit("EOF from manager.");
        }
        if ( $event eq '0' ) {
            sleep 1;
            next;
        }
        if ( defined ( $event->{'Event'} ) ) {
            if ( $event->{'Event'} =~ /OriginateResponse/i ) {
                Debugf("Response: %s", $event);
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
    }

    return $response;
}

sub sleep {
    my ($this, $timeout) = @_;
    Debug("Sleeping for $timeout seconds...");
    my $timeIn = time;
    while ($timeout >= ( time - $timeIn ) ) {
        my $event = $this->el->_getEvent();
        # Infof("%s",$event);
    }
    # Just read AMI with $timeout seconds
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

    unless ( defined ( $sent ) ) {
        die ("Can't send command ParkedCalls.\n");
    }

    my $reply = $this->mgr->receive_answer();

    unless ( defined ( $reply ) ) {
        die ("Can't receive answer\n");
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
        Err($this->mgr->geterror());
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

sub find_active_call {
    my $this = shift;
    my $dst  = shift;

    my @activechannels = $this->mgr->get_status();
    unless ( @activechannels ) {
        return undef;
    }
    my $i = 0; 
    while ( $i <= @activechannels) {
    	my $call = $activechannels[ $i++ ]; 
    	next unless defined $call->{'CallerIDNum'};
    	if ( $call->{'CallerIDNum'} eq $dst ) {
    		return $call;
    	}
    }
    return undef; 
}

sub set_callerid {
    my $this = shift;

    my $sth = $this->dbh->prepare("select get_callerid from routing.get_callerid (?,?)");
    eval { my $rv = $sth->execute($this->{src}, $this->{dst}); };
    if ($@) {
        $this->_exit("Can't get caller_id information: " . $this->dbh->errstr)
    }
    my $result = $sth->fetchrow_hashref;
    if ( $result->{'get_callerid'} eq '' ) { 
	$this->{callerid} = $this->{src}; 
    } else {
	$this->{callerid} = $result->{'get_callerid'} // $this->{src};
    }
}

sub route_call {
    my ( $this, $step, $try ) = @_;

    my $sth = $this->dbh->prepare(  "select * from routing.get_dial_route4 (?,?,?)" );
    eval { my $rv = $sth->execute( $this->{src}, $this->{dst}, $step ); };
    if ($@) {
        # ERROR: NO ROUTE
        Errf("Error: %s", $this->dbh->errstr);
        return undef;
    }
    my $result = $sth->fetchrow_hashref;
    $this->{dst_str}  = $result->{'dst_str'};
    $this->{dst_type} = $result->{'dst_type'};
    Debug("dst_str=".$this->{dst_str}.",dst_type=".$this->{dst_type}.",step=$step, try=$try");
    $this->{channel} = "SIP/" . $this->{dst_str} . "/" . $this->{dst};
    return 1;

}


1;
