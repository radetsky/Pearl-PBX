#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-parsequeuelog.pl
#
#        USAGE:  service PearlPBX-parsequeuelog start
#
#  DESCRIPTION:  This software parses /var/log/asterisk/queue.log and save results
#                to PostgreSQL.
#								 Version 2.0 - based on NetSDS::App now. Patched by rad@.
#
#      OPTIONS:  tail callback mailnotif --nodaemon --verbose , etc.
# REQUIREMENTS:  NetSDS, PearlPBX 
#         BUGS:  ---
#        NOTES:  ---
#		AUTHOR:  Anatoly Matyah (zmeuka), protopartorg@gmail.com
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  2.1
#      CREATED:  19/12/2010
#     MODIFIED:  12/12/2012 :) CAUSE: Add insert into VoiceInformer feature in case of ABANDON and tail
#     MODIFIED:  15/07/2013 Added e-mail notification 
#===============================================================================

=item queue_log

 id        | integer                | not null default nextval('queue_log_seq'::regclass)
 callid    | character varying(32)  |
 queuename | character varying(32)  |
 agent     | character varying(32)  |
 event     | character varying(32)  |
 data      | character varying(255) |
 time      | timestamp              |

=cut

=item queue_parsed

create table queue_parsed (
  id serial not null primary key,
  callid varchar(32) not null default '',
  queue varchar(32) not null default 'default',
  time timestamp not null,
  callerid varchar(32) not null default '',
  agentid varchar(32) not null default '',
  status varchar(32) not null default '',
  success integer not null default 0,
  holdtime integer not null default 0,
  calltime integer not null default 0,
  position integer not null default 0
);

Indexes:
    "queue_parsed_pkey" PRIMARY KEY, btree (id)
    "queue_parsed_agentid" btree (agentid)
    "queue_parsed_callerid" btree (callerid)
    "queue_parsed_callid" btree (callid)
    "queue_parsed_success" btree (success)

=cut

use strict;
use warnings;
use 5.8.0;

NetSDSParseQueueLog->run(
    daemon      => 1,
    verbose     => undef,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef
);

1;

package NetSDSParseQueueLog;

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use Data::Dumper;
use DBI;
use File::Tail;
use Getopt::Long qw(:config auto_version auto_help pass_through);
use MIME::Base64; 
use NetSDS::Util::DateTime;

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

	my $tail = undef; 
	GetOptions ('tail!' => \$tail);
    unless ( defined ( $tail ) ) { 
        $this->{'tail'} = 1; 
        $this->log('info','Tail mode enabled.'); 
    } else {
        $this->{'tail'} = $tail; 
        if ( $tail > 0 ) { 
            $this->log('info','Tail mode enabled.'); 
        } else { 
            $this->log('info','Tail mode disabled.'); 
        }
    }

    my $callback = undef; 
    GetOptions ('callback' => \$callback); 
    unless ( defined ( $callback) ) { 
        $this->{'callback'} = 0; 
        $this->log('info','Callback mode disabled.'); 
    } else { 
        $this->{'callback'} = 1; 
        $this->log('info','Callback mode enabled.'); 
    }

    my $mailnotif = undef; 
    GetOptions ('mailnotif' => \$mailnotif); 
    unless ( defined ( $mailnotif) ) { 
        $this->{'mailnotif'} = 0; 
        $this->log('info','Mail notifications disabled.'); 
    } else { 
        $this->{'mailnotif'} = 1; 
        $this->log('info','Mail notifications enabled.'); 
    }

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

    $this->{'st_log'} = $this->dbh->prepare(
"insert into queue_log (time,callid,queuename,agent,event,data) values (to_timestamp(?),?,?,?,?,?)"
    );
    $this->{'st_enterqueue'} = $this->dbh->prepare(
"insert into queue_parsed(time,callid,queue,callerid,agentid,status,success,holdtime,calltime,position) values (to_timestamp(?),?,?,?,?,?,0,0,0,0)"
    );
    $this->{'st_abandon'} = $this->dbh->prepare(
"update queue_parsed set position=?,holdtime=?,status=?,success=0 where callid=?"
    );
    $this->{'st_complete'} = $this->dbh->prepare(
"update queue_parsed set holdtime=?,calltime=?,position=?,status=?,agentid=?,success=1 where callid=?"
    );
    $this->{'st_connect'} = $this->dbh->prepare(
"update queue_parsed set holdtime=?,agentid=?,success=1,status='CONNECT' where callid=?"
    );
    $this->{'st_callback'} = $this->dbh->prepare(
        "insert into public.voiceinformer ( destination, userfield, till ) values ( ?, ?, ?)" ); 

    $this->{'st_callback_getinfo'} = $this->dbh->prepare ( 
        "select * from public.queue_parsed where callid=?"
        );

    return 1;

}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->speak($errstr);
    $this->log( 'warning', $errstr );

    exit(-1);
}

sub _callback { 
    my $this = shift; 
    my $callid = shift; 

    $this->{'st_callback_getinfo'}->execute($callid); 
    my $row = $this->{'st_callback_getinfo'}->fetchrow_hashref; 
    unless ( defined ( $row->{'callid'})) { 
        $this->log("warning","Can't find queue_parsed:callid=".$callid); 
        return undef; 
    }
    my $destination = $row->{'callerid'}; 
    my $queue = "QUEUE=".$row->{'queue'}; 
    my $interval = "now()+'10 minutes'::interval"; # FIXME  - it's a hardcode. 

    $this->{'st_callback'}->execute($destination,$queue,$interval); 
}

sub _russian_date { 
    my $this = shift; 

    my ($year,$mon,$mdy,$hour,$min,$sec) = date_now_array(); 

    my @months = ('0','Января','Февраля','Марта','Апреля','Мая','Июня','Июля',
        'Августа','Сентября','Октября','Ноября','Декабря'); 

    return sprintf('%s %s %s %d:%d',$mdy,$months[$mon],$year, $hour,$min); 

}
sub _mailnotif { 
    my ($this, $callid, $pos, $waittime) = @_; 

    $this->{'st_callback_getinfo'}->execute($callid); 
    my $row = $this->{'st_callback_getinfo'}->fetchrow_hashref; 
    unless ( defined ( $row->{'callid'})) { 
        $this->log("warning","Can't find queue_parsed:callid=".$callid); 
        return undef; 
    }
    my $callerid = $row->{'callerid'}; 
    my $queuename = $row->{'queue'}; 
    # We have a CALLERID, POSITION, WAITTIME. All we need to send mesage. 

    my $to = $this->{conf}->{'email'}; 
    unless ( defined ( $this->{conf}->{'email'} ) ) { 
        $this->log('warning','E-mail for notification does not configured.'); 
        $to = 'rad@rad.kiev.ua'; 
    }

    my $sendmail   = '/usr/sbin/sendmail';
    my $from       = $this->{conf}->{'email_from'};
    unless ( defined ( $this->{conf}->{'email_from'} )) { 
        $from = 'pearlpbx@pearlpbx.com'; 
    }

    if (length($callerid) == 9 ) { 
        $callerid = '0'.$callerid; # CityCom patch 
    } 
    
    my $subject = 'Пропущенный звонок с номера: '.$callerid; 
    my $russian_date = $this->_russian_date();  
    my $body = $russian_date. '<br>'. 
        'Номер: '. $callerid . '<br>' . 
        'Длительность: '.$waittime. ' сек. <br><br>';
 
    $body .= 'Группа: '. $queuename . '<br>';  
    $body .= "С уважением, PearlPBX-parsequeuelogd<br>";

    $subject = encode_base64($subject,''); 
    $body = encode_base64($body); 

    open( MAIL, "| $sendmail -t -oi" ) or die("$!");

    print MAIL <<EOF;
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64
From: $from
To: $to
Subject: =?UTF-8?B?$subject?=

$body
EOF

close MAIL;

}

sub process {
    my ($this,%params) = @_;

    my $filename = '/var/log/asterisk/queue_log';
    if ( defined( $this->{'conf'}->{'queue_log_filename'} ) ) {
        $filename = $this->{'conf'}->{'queue_log_filename'};
    }

    unless ( -f $filename ) {
        $this->_exit("File [$filename] does not exists");
    }

    my $ref = undef;

    unless ($this->{'notail'} ) {
        $this->speak("Begin to tail $filename");
        $this->log( "info", "Begin to tail $filename" );

        $ref = tie *LOG, "File::Tail",
          ( name => $filename );    # see perldoc File::Tail for fine tuning
    }
    else {
        $this->speak("Single parsing mode for $filename");
        $this->log( "info", "Single parsing mode for $filename" );
        open LOG, "<$filename"
          or $this->_exit("Can't open file [$filename]: $!");
    }

    while (<LOG>) {
        chomp;
        my ( $unixtime, $callid, $queue, $agent, $event, @par ) = split /\|/;
        if ($this->{verbose}) { 
            print join ( ',', $unixtime,$callid, $queue, $agent, $event, @par) ."\n"; 
        }

        # Logging
        $this->{'st_log'}->execute( $unixtime, $callid, $queue, $agent, $event,
            join( '|', @par ) );

        # Parsing events
        if ( $event eq 'ENTERQUEUE' ) {

            # New call arrived; catch'em!
            $par[1] .= '';    # avoid NULL inserts
            $this->{'st_enterqueue'}
              ->execute( $unixtime, $callid, $queue, $par[1], $agent, $event );
        }
        elsif ( ( $event eq 'ABANDON' ) or ( $event eq 'EXITEMPTY' ) ) {

      # The caller abandoned their position in the queue.
      # The caller was exited from the queue forcefully because the queue had no
      # reachable members and it's configured to do that to callers when there
      # are no reachable members.

            my ( $pos, $origpos, $waittime ) = @par;
            $pos      += 0;
            $waittime += 0;
            $this->{'st_abandon'}->execute( $pos, $waittime, $event, $callid );

            if ( ( $this->{'tail'} > 0 ) and ( $this->{'callback'} > 0) ) { 
                $this->_callback($callid); # Там уже из базы вытащим все необходимые параметры
            }
            if ( ( $this->{'tail'} > 0 ) and ( $this->{'mailnotif'} > 0) ) { 
                $this->_mailnotif ($callid, $pos, $waittime ); 
            }

        }
        elsif (( $event eq 'COMPLETEAGENT' )
            or ( $event eq 'COMPLETECALLER' ) )
        {

# The caller was connected to an agent, and the call was terminated normally by the agent or caller.
            my ( $holdtime, $calltime, $pos ) = @par;
            $holdtime += 0;
            $calltime += 0;
            $pos      += 0;
            $this->{'st_complete'}
              ->execute( $holdtime, $calltime, $pos, $event, $agent, $callid );
        }
        elsif ( $event eq 'CONNECT' ) {

            # The caller was connected to an agent.
            my $holdtime = $par[0] + 0;
            $this->{'st_connect'}->execute( $holdtime, $agent, $callid );
        }
        elsif ( $event eq 'EXITWITHKEY' ) {
            my $pos = $par[1] + 0;
            $this->{'st_abandon'}->execute( $pos, 0, $event, $callid );
        }
        elsif ( $event eq 'EXITWITHTIMEOUT' ) {
            my $pos = $par[0] + 0;
            $this->{'st_abandon'}->execute( $pos, 0, $event, $callid );
        }
    }    #end while(1)...
}

