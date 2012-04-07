#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  missedcallnotification.pl
#
#        USAGE:  ./missedcallnotification.pl 
#
#  DESCRIPTION:  Look into CDR, tail -f where dstchannel is '' and mail it to whom it may concern 
#								 /etc/NetSDS/asterisk-router.conf  
#
#      OPTIONS:  ---
# REQUIREMENTS:  --- Perl NetSDS Framework
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  29.03.2012 13:37:04 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

PearlPBXMissedCallNotification->run(
	daemon => undef, 
	verbose => 1, 
	use_pidfile => 1, 
	has_conf => 1, 
	conf_file   => "/etc/NetSDS/asterisk-router.conf",
	infinite    => undef
);

1; 

package PearlPBXMissedCallNotification; 

use 5.8.0;
use strict; 
use warnings; 

use base qw(NetSDS::App);
use DBI; 

sub start {
    my $this = shift;

    $SIG{TERM} = sub {
        exit(-1);
    };
    $SIG{INT} = sub {
        exit(-1);
    };

    $this->mk_accessors('dbh');
    $this->_db_connect();

}

sub _db_connect {
    my $this = shift;

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->speak("Can't find \"db main->dsn\" in configuration.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->speak("Can't find \"db main->login\" in configuraion.");
        exit(-1);
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->speak("Can't find \"db main->password\" in configuraion.");
        exit(-1);
    }

    my $dsn    = $this->conf->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->conf->{'db'}->{'main'}->{'login'};
    my $passwd = $this->conf->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->dbh or !$this->dbh->ping ) {
        $this->dbh(
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }

	  return 1; 
}

=item 

  _exit (errstr) 
	Abnormal termination. 

=cut 

sub _exit { 

	my $this = shift; 
	my $errstr = shift; 
	
	$this->log("error", $errstr); 
	exit(-1); 
} 

sub _get_last_calldate { 
	my $this = shift;

	if (defined ( $this->{'last_calldate'} ) ) { 
		return $this->{'last_calldate'};
	} 

  # -1. select calldate from public.cdr order by calldate desc limit 1;  # remember calldate; 
  # Just get latest record to remember it.
	my $sth = $this->dbh->prepare("select calldate from public.cdr order by calldate desc limit 1"); 
  eval { 
		my $rv = $sth->execute; 
	}; 
	if ($@) { 
		$this->_exit($this->dbh->errstr); 
	} 
	my $last_calldate = $sth->fetchrow_hashref;
  # last_calldate may have undef value if cdr table is empty; 
	$this->dbh->rollback;

  $this->{'last_calldate'} = $last_calldate; 
	return $last_calldate; 
}

sub _get_data {

	my $this = shift; 
	my $channels = shift;
	my $last_calldate = shift;

	my $result_hashref = undef; 

  my $sql = "select calldate,src,dst,channel from public.cdr where dstchannel = '' and channel similar to (".$this->dbh->escape($channels).") ";
  if ( defined ( $last_calldate ) ) { 
		$sql .= "and calldate > '$last_calldate' "; 
	} 
	$sql .= "order by calldate;"; 
	
	eval { 
		$result_hashref = $this->dbh->selectall_hashref($sql,'calldate'); 
	};
	if ($@) { 
		$this->_exit($this->dbh->errstr); 
	} 
	$this->dbh->rollback; 
	return $result_hashref; 

}
sub _send_notify { 
	my $this = shift; 
	my $addr = shift; 
	my $subj = shift; 
	my $body = shift; 

	$this->log("info","Send notify to $addr"); 


}
sub _notify {
	my $this = shift; 
	my $missed_hashref = shift; 

  # We have {'calldate'},{'src'},{'dst'},{'channel'}; 
	# We need to create a e-mail and send it to...

	my $subject = "Attention! Missed call."; 
	my $body = "Missed call from ". $missed_hashref->{'src'} . " to " . $missed_hashref->{'dst'} . "\n"; 
	$body .= "Time: ".$missed_hashref->{'calldate'} . "\n"; 
	$body .= "Source channel: ".$missed_hashref->{'channel'}."\n"; 
	$body .= "--\nBest,\nYour PBX."; 

	my $dst = $missed_hashref->{'dst'}; 
	my $address = undef; 

  if ( defined ( $this->conf->{'missedcallnotification'}->{'mailto'}->{$dst} ) ) {  
	   my $mailto_address = $this->conf->{'missedcallnotification'}->{'mailto'}->{$dst}; 
		 my (@addrs) = split(',',$mailto_address); 

		 foreach my $addr (@addrs) { 
		 	$this->_send_notify($addr,$subject,$body); 
		 }
		 return 1; 
	} 
  return undef; 

} 
sub process { 
	my $this = shift; 

  my $last_calldate = $this->_get_last_calldate;
	unless ( defined ( $last_calldate ) ) { 
		$this->log("error","CDR table is empty. Calldate is undef.");
	} else { 
		$this->log("info","CDR calldate is " . $last_calldate . ". Begin to tail CDR table."); 
	} 
	
	unless ( defined ( $this->conf->{'missedcallnotification'} ) ) { 
		$this->_exit("Missed configuration part for 'Missed Calls Notification' function."); 
	}
  unless ( defined ( $this->conf->{'missedcallnotification'}->{'channel'} ) ) { 
    $this->_exit("Missed 'channel' configuration part for 'Missed Calls Notification' function."); 
	}
  unless ( defined (  $this->conf->{'missedcallnotification'}->{'mailto'} ) ) { 
    $this->_exit("Missed 'mailto' configuration part for 'Missed Calls Notification' function.");
	} 

  my $missconfig = $this->conf->{'missedcallnotification'}; 
  my $channel_list = $missconfig->{'channel'}; 

# 0. select calldate,src,dst,channel from public.cdr where dstchannel = '' and channel=? and calldate >? 
  
	my $channels = join ('|' , keys %$channel_list ); 
  my $missedrecords = $this->_get_data($channels,$last_calldate);

  if ( $missedrecords == {} ) { 
		$this->log("info","No missed calls. Wait for 1 minute."); 
		sleep(60); 
		return 1; 
  } 	

  foreach my $missedcall ( keys %$missedrecords ) { 
	   $this->_notify($missedrecords->{$missedcall});   	
		 $this->{'last_calldate'} = $missedrecords->{$missedcall}->{'calldate'}; 
  }
  sleep(60); 
  return 1; 
}

1;
#===============================================================================

__END__

=head1 NAME

missedcallnotification.pl

=head1 SYNOPSIS

missedcallnotification.pl

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

