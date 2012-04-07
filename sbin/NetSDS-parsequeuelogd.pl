#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-parsequeuelog.pl
#
#        USAGE:  service NetSDS-parsequeuelog start
#
#  DESCRIPTION:  This software parses /var/log/asterisk/queue.log and save results
#                to PostgreSQL.
#								 Version 2.0 - based on NetSDS::App now. Patched by rad@.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#				AUTHOR:  Anatoly Matyah (zmeuka), protopartorg@gmail.com
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  2.0
#      CREATED:  19/12/2010
#     REVISION:  001
#     MODIFIED:  16/01/2012
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

	my $notail = undef; 

	GetOptions ('notail!' => \$notail); 
	
	$this->{'notail'} = $notail; 

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

    return 1;
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->speak($errstr);
    $this->log( 'warning', $errstr );

    exit(-1);
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

    #FIXME: проверить передачу параметра --notail
    my $tail = 1;
    if ( defined( $this->{'notail'} ) ) {
        $tail = 0;
    }

    my $ref = undef;

    if ($tail) {
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

