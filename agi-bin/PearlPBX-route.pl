#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  PearlPBX-route.pl
#  DESCRIPTION:
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      VERSION:  2.0
#      CREATED:  2011-11-30 21:22:55 EET
#LAST MODIFIED:  2016-03-27
#===============================================================================

use strict;
use warnings;

$| = 1;

Router->run(
    conf_file   => '/etc/NetSDS/asterisk-router.conf',
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Router;

use base 'NetSDS::App';
use Data::Dumper;
use Asterisk::AGI;
use File::Path;
use NetSDS::Asterisk::Manager;
use NetSDS::Util::Translit qw/trans_cyr_lat/;
use NetSDS::Util::String qw/str_trim/;
use Net::LDAP;

sub start {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->speak(
            "Usage: " . $this->name . ' ${CHANNEL} ' . '${EXTEN}' . "\n" );
        exit(-1);
    }
    unless ( defined( $ARGV[1] ) ) {
        $this->speak(
            "Usage: " . $this->name . ' ${CHANNEL} ' . '${EXTEN}' . "\n" );
        exit(-1);
    }

    $this->mk_accessors('dbh');
    $this->mk_accessors('agi');

    $this->agi( new Asterisk::AGI );
    $this->agi->ReadParse();
    $this->agi->_debug(10);

}

sub _cutoff_channel {
    my $this    = shift;
    my $channel = shift;
    my ( $proto, $a ) = split( '/', $channel );
    my ( $peername, $channel_number ) = split( '-', $a );

    unless ( defined($proto) ) {
        $this->speak("Can't recognize protocol of this channel.");
        exit(-1);
    }

    unless ( defined($peername) ) {
        $this->speak("Can't recognize peername of this channel.");
        exit(-1);
    }

    unless ( defined($channel_number) ) {
        $this->speak("Can't recognize channel_number of this channel.");
        exit(-1);
    }

    return ( $proto, $peername, $channel_number );
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
            DBI->connect ( $dsn, $user, $passwd, { AutoCommit => 1, RaiseError => 1 } )
        );
    }

    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
    }

    if ( $this->{verbose} ) {
        $this->agi->verbose( "Database connected.", 3 );
    }
    return 1;
}

sub _get_permissions {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;

    my $sth = $this->dbh->prepare("select * from routing.get_permission (?,?)");
    eval { my $rv = $sth->execute( $peername, $exten ); };
    if ($@) {
        # raised exception
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    my $perm   = $result->{'get_permission'};
    if ( $perm > 0 ) {
        $this->agi->verbose( "$peername has permissions to $exten", 3 );
    } else {
        $this->agi->verbose( "$peername does not have the rights to $exten !", 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    return;
}

=item B<_get_callerid(peername,exten)

  Функция предназначена для определения необходимости изменения текущего CallerID при звонках
    на указанный номер exten с указанного peername

    Пример ситуации заключается в том, что абоненту номер 201 надо позвонить на номер 0671231231.
    Для этого есть направление LifeSIP, которое не пускает звонки с левыми CallerID.
    Для таких случаев устанавливаем, что абоненту 201 требуется установить CallerID=0631231231
    для звонков по направлению LifeSIP.

    Хранимая процедура routing.get_callerid самостоятельно разберётся с выданными ей параметрами
    и выдаст результат в String.

=cut

sub _get_callerid {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;

    my $sth;
    my @params;
    my $result_name; 

    $this->agi->verbose("_get_callerid begins", 3);
    if ( $this->{proto} eq 'Local' ) {
        $sth = $this->dbh->prepare(
            "select * from routing.get_callerid_for_local_forward (?)");
        push @params, $exten;
	$result_name = 'get_callerid_for_local_forward'; 

    } else {
        $sth = $this->dbh->prepare("select * from routing.get_callerid (?,?)");
        push @params, $peername, $exten;
	$result_name = 'get_callerid'; 
    }

    $this->agi->verbose("Protocol: ".$this->{proto} . "/" . $peername . "->".$exten , 3); 
    eval { my $rv = $sth->execute(@params); };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result   = $sth->fetchrow_hashref;
    my $callerid = $result->{$result_name};

    my $set_own = undef;
    if ( $callerid ne '' ) {
        # Зачастую внешние устройства типа шлюзов FXO-SIP или GSM-SIP ставят в callerid(num)
        # свой локальный номер, например, 1001.
        # А реальный пришедший номер типа 380501231231 подставляют в callerid(name).
        # Значение NAME в правилах преобразования callerid служит именно для цели получения
        # корректного номера из callerid(name).

        if ( $callerid =~ /^NAME/i ) {
            $this->agi->verbose( "CHANGING NUM TO NAME.", 3 );
            $callerid = $this->agi->get_variable("CALLERID(name)");
            $callerid = $this->_cut_the_plus($callerid);
        } else {
            # Устанавливаем признак того, что номер поставили "свой", то есть для "своих нужд"
            # и его преобразовывать не надо.
            $set_own = 1;
        }

        $this->agi->verbose(
            "$peername have to set CallerID to \'$callerid\' while calling to $exten",
            3
        );

        unless ( defined ($set_own) ) {
            # Если не меняли номер на свой, а требуется его обрезать до национальго формата,
            # для удобства набора, то проводим такую операцию.
            # Конфиг-> telephony->local_country_code + local_number_length

            $callerid = $this->_cut_local_callerid($callerid);
        }

        $this->agi->exec( "Set", "CALLERID(all)=$callerid" );
        $this->{callerid_num} = $callerid;

    } else {
        unless ( defined ( $set_own ) ) {
            # Esli my ne menyali nomer na svoj. To obrezaem do 10 cyfr.
            $callerid = $this->agi->get_variable("CALLERID(num)");
            $callerid = $this->_cut_the_plus($callerid);
            $callerid = $this->_cut_local_callerid($callerid);
            $this->agi->exec( "Set", "CALLERID(all)=$callerid" );
            $this->{callerid_num} = $callerid;
        }
        $this->agi->verbose( "$peername does not change own CallerID", 3 );
    }
    return;
}

=item B<cut_the_plus(string)>

    Вырезает первый "+", если он там есть

=cut

sub _cut_the_plus {
    my $this = shift;
    my $str  = shift;

    $this->log( "info", "_cut_the_plus: $str" );

    my $first = substr( $str, 0, 1 );
    if ( $first eq '+' ) {
        return substr( $str, 1 );
    }
    else {
        return $str;
    }

}

=item B<cut_local_callerid(callerid)>

 Проводит преобразование номера исходя из соображений национального формата
 Для Украины принято оставлять из номера 380441231231 -> 0441231231

=cut

sub _cut_local_callerid {
    my $this     = shift;
    my $callerid = shift;

    my $local_country_code  = $this->conf->{'telephony'}->{'local_country_code'} // 'NULL';
    my $local_number_length = $this->conf->{'telephony'}->{'local_number_length'} // 10;

    my $calleridlen = length($callerid);
    if ( $calleridlen > $local_number_length ) {

        # Длина входящего номера больше чем длина национального,
        # Значит будем обрезать.
        if ( $callerid =~ /^$local_country_code/ ) {

            # Еще и попал под regexp с началом номера с национального кода ?
            # Точно будем обрезать
            $callerid = substr( $callerid, $calleridlen - $local_number_length,
                $local_number_length );
        }
    }
    return $callerid;
}

# Поиск роутинга для канала Local

sub _get_local_route {
    my $this  = shift;
    my $exten = shift;
    my $try   = shift;

    my $sth = $this->dbh->prepare("select * from routing.get_dial_route5 (?,?)");
    eval { my $rv = $sth->execute( $exten, $try ); };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Busy", "5" );
        $this->agi->exec( "Hangup",   "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    return $result;
}

sub _get_dial_route {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;
    my $try      = shift;

    my $sth = $this->dbh->prepare(  "select * from routing.get_dial_route4 (?,?,?)" );
    eval { my $rv = $sth->execute( $peername, $exten, $try ); };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Busy", "5" );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    return $result;

}

sub _convert_extension {
    my $this  = shift;
    my $input = shift;

    my $output = $input;
    my $result = undef;

    my $sth = $this->dbh->prepare ( "select id,exten,operation,parameters,step
        from routing.convert_exten where ? ~ exten order by id,step" );
    eval { my $rv = $sth->execute($input); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }

    eval { $result = $sth->fetchall_hashref('id'); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    unless ( defined($result) ) {
        return $input;
    }
    if ( $result == {} ) {
        return $input;
    }
    foreach my $id ( sort keys %$result ) {
        my $operation  = $result->{$id}->{'operation'};
        my $parameters = $result->{$id}->{'parameters'};
        my ( $param1, $param2 ) = split( ':', $parameters );
        if ( $operation =~ /concat/ ) {
            if ( $this->{debug} ) {
                $this->log( "info",
                    "convert extension: concat '$param1':'$param2'" );
            }

            # second param contains 'begin' or 'end'
            if ( $param2 =~ /begin/ ) {
                $output = $param1 . $output;
            }
            if ( $param2 =~ /end/ ) {
                $output = $output . $param1;
            }
        }
        if ( $operation =~ /substr/ ) {

            # first param - position of beginning. Example: black : substr 2,3 = ack
            # second param - if empty substr till the end.
            if ( $this->{debug} ) {
                $this->log( "info",
                    "convert extension: substr '$param1':'$param2'" );
            }

            unless ($param1) {
                $param1 = 0;
            }
            unless ($param2) {
                $output = substr( $output, $param1 );
            }
            else {
                $output = substr( $output, $param1, $param2 );
            }
        }
    }
    return $output;
}

sub _mixmonitor_filename {
    my $this         = shift;
    my $cdr_start    = shift;
    my $callerid_num = shift;
    my $uniqueid     = shift;

    $cdr_start =~ /(\d{4})-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})/;

    my $year = $1;
    my $mon  = $2;
    my $day  = $3;
    my $hour = $4;
    my $min  = $5;
    my $sec  = $6;

    my $directory
        = sprintf( "/var/spool/asterisk/monitor/%s/%s/%s", $year, $mon,
        $day );

    my $filename = sprintf( "%s/%s/%s/%s%s%s-%s-%s.wav",
        $year, $mon, $day, $hour, $min, $sec, $callerid_num, $uniqueid );

    return ( $directory, $filename );

}

sub _init_mixmonitor {
    my $this = shift;

    if ( $this->{conf}->{'mixmonitor'} =~ /yes/ ) {
        my $cdr_start    = $this->agi->get_variable('CDR(start)');
        my $callerid_num = $this->agi->get_variable('CALLERID(num)');
        my $uniqueid     = $this->agi->get_variable('CDR(uniqueid)');
        my ( $directory, $filename )
            = $this->_mixmonitor_filename( $cdr_start, $callerid_num, $uniqueid );
        mkpath($directory);
        $this->agi->exec( "MixMonitor", "$filename" );
        $this->save_mixmonitor_params ( $callerid_num, $cdr_start, $uniqueid, $filename );
    }
}

sub save_mixmonitor_params {
    my $this          = shift;
    my $callerid_num  = shift;
    my $cdr_start     = shift;
    my $uniqueid      = shift;
    my $original_file = shift;

    my $cdr_src  = $this->agi->get_variable('CDR(src)');
    my $cdr_dst  = $this->agi->get_variable('CDR(dst)');

    $this->_begin;
    my $sth = $this->dbh->prepare (
        "insert into integration.recordings \
        (original_file,cdr_start,cdr_src,cdr_dst,cdr_uniqueid,next_record) \
        values (?,?,?,?,?,0)" );

    eval {
        my $rv = $sth->execute( $original_file, $cdr_start, $cdr_src,
            $cdr_dst, $uniqueid );
    };

    if ( $@ ) {
        $this->_exit( $this->dbh->errstr );
    }

    $this->dbh->commit;
    $this->agi->verbose ( "Save mixmonitor params: $cdr_start, $cdr_src, $cdr_dst, $uniqueid", 3);
}

sub _begin {
    my $this = shift;

    eval { $this->dbh->begin_work; };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->log( "warning", $errstr );
    $this->agi->verbose( $errstr, 3 );
    $this->agi->exec( "Hangup", "17" );
    exit(-1);
}

sub _set_callerid_name {
    my ( $this, $callerid_num ) = @_;

    my $caller_name = $this->_get_callername ( $callerid_num );
    unless ( defined ( $caller_name ) ) {
        $this->agi->exec( "Set", "CALLERID(name)=$callerid_num" );
        $this->{'callerid_name'} = "$callerid_num";
    } else {
        $this->agi->exec( "Set", "CALLERID(name)=$caller_name" );
        $this->{'callerid_name'} = "$caller_name";
    }
}

sub _get_term {
    my ( $this, $name ) = @_;
    my $sql = "select a.name, b.teletype from public.sip_peers a, integration.workplaces b where a.name=? and a.id=b.sip_id";
    my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute($name); };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr );
        exit(-1);
    }
    my $res = $sth->fetchrow_hashref;
    return $res->{'teletype'};
}

sub _translit_callerid_name {
    my $this = shift;

    $this->agi->exec( "Set",
        "CALLERID(name)=" . trans_cyr_lat( $this->{'callerid_name'}, 'ru' ) );

}

sub _get_callername {

    my ( $this, $callerid ) = @_;

    # Приоритет имеет LDAP, но если _ldap_search вернет undef, то мы продолжим использовать локальную базу.
    my $ldap_result = $this->_ldap_search($callerid);
    if ( defined($ldap_result) ) {
        return $ldap_result;
    }

    my $sql = "select comment from public.sip_peers where name=?";
    my $adr = "select displayname from ivr.addressbook where msisdn=?";

    $this->agi->verbose( "Searching for $callerid in local sip_peers...", 3 );

    my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute($callerid) };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr );
        exit(-1);
    }
    my $res         = $sth->fetchrow_hashref;
    my $displayname = $res->{'comment'};

    if ( defined($displayname) and ( $displayname ne '' ) ) {
        return $displayname;
    }

    $this->agi->verbose( "Searching for $callerid in ivr.addressbook...", 3 );

    $sth = $this->dbh->prepare($adr);
    eval { $sth->execute($callerid) };
    if ($@) {
        $this->agi->verbose( $this->dbh->errstr );
        exit(-1);
    }
    $res         = $sth->fetchrow_hashref;
    $displayname = $res->{'displayname'};

    if ( defined($displayname) and ( $displayname ne '' ) ) {
        return $displayname;
    }

    return undef;

}

sub _ldap_search {
    my ( $this, $callerid ) = @_;
    
    $this->log( "info", "LDAP searching" );
    unless ( defined( $this->{conf}->{'ldap'}->{'host'} ) ) {
        $this->log( "info", "LDAP host not defined" );
        return undef;
    }
    my $ldap = Net::LDAP->new( $this->{conf}->{'ldap'}->{'host'} )
        or return undef;

    unless ( defined( $this->{conf}->{'ldap'}->{'user'} ) ) {
        $this->log( "info", "LDAP user not defined" );
        return undef;
    }
    unless ( defined( $this->{conf}->{'ldap'}->{'password'} ) ) {
        $this->log( "info", "LDAP password not defined" );
        return undef;
    }
    my $mesg = $ldap->bind( $this->{conf}->{'ldap'}->{'user'},
        password => $this->{conf}->{'ldap'}->{'password'} );

    unless ( defined( $this->{conf}->{'ldap'}->{'base'} ) ) {
        $this->log( "info", "LDAP base not defined" );
        return undef;
    }
    
    my $base = $this->{conf}->{'ldap'}->{'base'};
    unless ( defined( $this->{conf}->{'ldap'}->{'filter'} ) ) {
        $this->log( "info", "LDAP filter not defined" );
        return undef;
    }
     my $filter = sprintf( $this->{conf}->{'ldap'}->{'filter'}, $callerid,
        $callerid );
    $this->log( "info", "LDAP filter: $filter" );
 		$this->agi->verbose( "Searching for $callerid in LDAP...", 3 );
    my $result = $ldap->search( base => $base, filter => $filter );

    foreach my $entry ( $result->entries ) {

        # print Dumper $entry->{'asn'}->{'objectName'};
        foreach my $attr ( @{ $entry->{'asn'}->{'attributes'} } ) {
            if ( $attr->{'type'} eq 'sn' ) {
                $this->log( "info", "LDAP found " . $attr->{'vals'}[0] );
                return $attr->{'vals'}[0];
            }
        }
    }
    $this->log( "info", "LDAP search not found anything" );
    return undef;
}

sub _manager_connect {
    my $this = shift;

    # connect
    unless ( defined( $this->conf->{'el'}->{'host'} ) ) {
        $this->_exit("Can't file el->host in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'port'} ) ) {
        $this->_exit("Can't file el->port in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'username'} ) ) {
        $this->_exit("Can't file el->username in configuration.");
    }
    unless ( defined( $this->conf->{'el'}->{'secret'} ) ) {
        $this->_exit("Can't file el->secret in configuration.");
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
        events   => 'Off'
    );

    my $connected = $manager->connect;
    unless ( defined($connected) ) {
        $this->_exit("Can't connect to the asterisk manager interface.");
    }
    return $manager;

}

sub _get_status {
    my $this    = shift;
    my $manager = shift;

    my $sent = $manager->sendcommand( 'Action' => 'Status' );
    unless ( defined($sent) ) {
        return undef;
    }
    my $reply = $manager->receive_answer();
    unless ( defined($reply) ) {
        return undef;
    }
    my $status = $reply->{'Response'};
    unless ( defined($status) ) {
        return undef;
    }
    if ( $status ne 'Success' ) {
        $this->seterror('Status: Response not success');
        return undef;
    }

    # reading from spcket while did not receive Event: StatusComplete
    my @replies;
    while (1) {
        $reply  = $manager->receive_answer();
        $status = $reply->{'Event'};
        if ( $status eq 'StatusComplete' ) {
            last;
        }
        push @replies, $reply;
    }
    return @replies;
}

sub _send_message {
    my ( $this, $from, $dst, $text ) = @_;

    $this->agi->exec( "Set",         "MESSAGE(body)=$text" );
    $this->agi->exec( "MessageSend", "sip:$dst,$from" );

}

sub _queue_message {
    my ( $this, $from, $dst, $text ) = @_;
    $this->agi->exec( "System",
              "/usr/local/bin/astqueue.sh -SRC '"
            . $from
            . "' -DST '"
            . $dst
            . "' -MSG '"
            . $text
            . "'" );
}

sub _global_blacklist { 
    my ($this, $callerid_num) = @_; 

  my $sql = "select count(*) as blacklisted from public.blacklist where number=?"; 
  my $sth = $this->dbh->prepare($sql);
  eval { $sth->execute ( $callerid_num ); }; 
  if ( $@ ) { 
    $this->agi->verbose ( $this->dbh->errstr ); 
    exit(-1);
  }
  my $res = $sth->fetchrow_hashref; 
  my $blacklisted = $res->{'blacklisted'}; 
    
  $this->agi->set_variable ('BLACKLISTED','0'); 
  if ( $blacklisted > 0 ) { 
    $this->agi->set_variable ('BLACKLISTED',$blacklisted); 
    $this->agi->exec("Hangup","17"); 
  }
  return;
}

sub process {
    my $this = shift;

    my $channel   = $ARGV[0];
    my $extension = $ARGV[1];

    my $dialstatus = undef;

    $this->{'channel'} = $channel;
    $this->{'exten'}   = $extension;

    # split the channel name

    ( $this->{proto}, $this->{peername}, $this->{channel_number} )
        = $this->_cutoff_channel($channel);

    $this->{channel}   = $channel;
    $this->{extension} = $extension;

    # Set timeout(absolute)
    $this->agi->set_variable( "TIMEOUT(absolute)", "3600" );

    # Connect to the database
    $this->_db_connect();

    # Установка номера А. Если используется канал Local, то эта функция игнорируется.
    $this->_get_callerid( $this->{peername}, $this->{extension} );
    $this->_set_callerid_name($this->{callerid_num});

    # Global blacklist 
    $this->_global_blacklist($this->{'callerid_num'}); 

    # Init MixMonitor
    $this->_init_mixmonitor();

    # Проверка прав доступа.  Если используется канал "Local", то эта функция игнорируется.
    if ( $this->{proto} ne "Local" ) {
        $this->_get_permissions( $this->{peername}, $this->{extension} );
    }

    # Convert extension
    $extension = $this->_convert_extension( $this->{'extension'} );

    my $tgrp_first;

    # Get dial route
    for ( my $current_try = 1; $current_try <= 5; $current_try++ ) {
        $this->agi->verbose(
            "Call _get_dial_route("
                . $this->{peername} . ","
                . $this->{extension} . ","
                . $current_try . ")",
            3
        );
        my $result = undef;
        if ( $this->{proto} ne "Local" ) {
            $result = $this->_get_dial_route( $this->{peername},
                $this->{extension}, $current_try );
        }
        else {
            $result
                = $this->_get_local_route( $this->{extension}, $current_try );
        }
        unless ( defined($result) ) {
            $this->log( "warning",
                "SOMETHING WRONG. _get_dial_route returns undefined value." );
            $this->agi->verbose(
                "SOMETHING WRONG!  _get_dial_route returns undefined value.",
                3
            );
            die "SOMETHING WRONG!  _get_dial_route returns undefined value.";
        }

        my $dst_str  = $result->{'dst_str'};
        my $dst_type = $result->{'dst_type'};
        $current_try = $result->{'try'};
        $this->agi->verbose(
            "dst_str=$dst_str,dst_type=$dst_type,try=$current_try", 3 );
        my $res = undef;

        if ( ( $dst_type eq "user" ) or ( $dst_type eq "lmask" ) ) {
            my $terminal = $this->_get_term($dst_str);
            if (   ( $terminal =~ /GrandStreamGXP1200/ )
                or ( $terminal =~ /oldhardphone/ ) )
            {
                $this->_translit_callerid_name();
            }
            $this->agi->verbose( "Dial SIP/$dst_str", 3 );
            $res = $this->agi->exec( "Dial", "SIP/$dst_str,120,tT" );
            $this->agi->verbose( "result = $res", 3 );
            $dialstatus = $this->agi->get_variable("DIALSTATUS");
            $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
            if ( $dialstatus =~ /^ANSWER/ ) {
                exit(0);
            }
            if ( $dialstatus =~ /^BUSY/ ) {
                if (    ( $this->{conf}->{'textsupport'} =~ /yes/ )
                    and ( $this->{conf}->{'textnotify'} =~ /yes/ ) )
                {
                    $this->_send_message( "ServiceCenter", $dst_str,
                              "Vam zvonil abonent "
                            . $this->{callerid_name} . "<"
                            . $this->{callerid_num}
                            . ">" );
                    $this->_send_message( "ServiceCenter",
                        $this->{callerid_num}, "Abonent $dst_str zanyat." );
                }
                $this->agi->exec( "Busy",   "5" );
                $this->agi->exec( "Hangup", "17" );
                exit(0);
            }
            else {
                if (    ( $this->{conf}->{'textsupport'} =~ /yes/ )
                    and ( $this->{conf}->{'textnotify'} =~ /yes/ ) )
                {
                    $this->_queue_message( "ServiceCenter", $dst_str,
                              "Vam zvonil abonent "
                            . $this->{callerid_name} . "<"
                            . $this->{callerid_num}
                            . ">" );
                    $this->_send_message(
                        "ServiceCenter",
                        $this->{callerid_num},
                        "Абонент $dst_str не может принять звонок, потому что он недоступен."
                    );
                }
            }
        }
        if ( $dst_type eq "trunk" ) {
            $this->agi->verbose( "Dial SIP/$dst_str/$extension", 3 );
            $res = $this->agi->exec( "Dial",
                "SIP/$dst_str/$extension,120,tTg" );
            $this->agi->verbose( "result = $res", 3 );
            $dialstatus = $this->agi->get_variable("DIALSTATUS");
            $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
            if ( $dialstatus =~ /^ANSWER/ ) {
                exit(0);
            }
            if ( $dialstatus =~ /^BUSY/ ) {
                $this->agi->exec( "Busy",   "5" );
                $this->agi->exec( "Hangup", "17" );
                exit(0);
            }
        }

        if ( $dst_type eq 'context' ) {
            $this->agi->verbose("Goto context $dst_str/$extension");
            $res = $this->agi->exec( "Goto", "$dst_str,$extension,1" );
            exit(0);
        }

        if ( $dst_type eq 'tgrp' ) {
            unless ( defined($tgrp_first) ) {
                $tgrp_first = $dst_str;
                $this->agi->verbose( "tgrp_first = $dst_str", 3 );
                $this->agi->verbose("EXEC DIAL SIP/$dst_str/$extension");
                $res = $this->agi->exec( "Dial",
                    "SIP/$dst_str/$extension,120,tTg" );
                $this->agi->verbose( "result = $res", 3 );
                $dialstatus = $this->agi->get_variable("DIALSTATUS");
                $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
                if ( $dialstatus =~ /^ANSWER/ ) {
                    exit(0);
                }
                if ( $dialstatus =~ /^BUSY/ ) {
                    $this->agi->exec( "Busy",   "5" );
                    $this->agi->exec( "Hangup", "17" );
                    exit(0);
                }
                next;
            }
            if ( $dst_str eq $tgrp_first ) {
                $current_try = $current_try + 1;
                $tgrp_first  = undef;
                $this->agi->verbose(
                    "$dst_str = $tgrp_first. current_try++ = $current_try",
                    3 );
                next;
            }
            $this->agi->verbose("current_try = $current_try");
            $res = $this->agi->exec( "Dial",
                "SIP/$dst_str/$extension,120,tTg" );
            $this->agi->verbose( "result = $res", 3 );
            $dialstatus = $this->agi->get_variable("DIALSTATUS");
            $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
            if ( $dialstatus =~ /^ANSWER/ ) {
                exit(0);
            }
            if ( $dialstatus =~ /^BUSY/ ) {
                $this->agi->exec( "Busy",   "5" );
                $this->agi->exec( "Hangup", "17" );
                exit(0);
            }

        }    # End of (if tgrp)

    }    # End of for (1...5)
    $this->agi->exec ( "Busy", "5" );
    $this->agi->exec ( "Hangup", "17" );

}    # End of process();

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

