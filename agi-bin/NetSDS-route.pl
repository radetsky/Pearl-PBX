#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-route.pl
#
#        USAGE:  ./NetSDS-route.pl
#
#  DESCRIPTION:
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  11/30/11 21:22:55 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
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
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
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

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth = $this->dbh->prepare("select * from routing.get_permission (?,?)");

    eval { my $rv = $sth->execute( $peername, $exten ); };
    if ($@) {

        # raised exception
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    my $perm   = $result->{'get_permission'};
    if ( $perm > 0 ) {
        $this->agi->verbose( "$peername has permissions to $exten", 3 );
        $this->log( "info", "$peername has permissions to $exten" );
    }
    else {
        $this->agi->verbose( "$peername does not have the rights to $exten !",
            3 );
        $this->log( "warning",
            "$peername does not have the rights to $exten !" );
        $this->dbh->rollback();
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }

    $this->dbh->commit();
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

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth = $this->dbh->prepare("select * from routing.get_callerid (?,?)");

    eval { my $rv = $sth->execute( $peername, $exten ); };
    if ($@) {

        # raised exception
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    my $result   = $sth->fetchrow_hashref;
    my $callerid = $result->{'get_callerid'};

    my $set_own = undef;
    if ( $callerid ne '' ) {

# Зачастую внешние устройства типа шлюзов FXO-SIP или GSM-SIP ставят в callerid(num)
# свой локальный номер, например, 1001.
# А реальный пришедший номер типа 380501231231 подставляют в callerid(name).
# Значение NAME в правилах преобразования callerid служит именно для цели получения
# корректного номера из callerid(name).

        if ( $callerid =~ /^NAME/i ) {
            $this->agi->verbose( "CHANGING NUM TO NAME.", 3 );
            $this->log( "info", "CHANGING NUM TO NAME." );
            $callerid = $this->agi->get_variable("CALLERID(name)");
            $callerid = $this->_cut_the_plus($callerid);
            $callerid = $this->_cut_the_lineX($callerid);
        }

# Устанавливаем признак того, что номер поставили "свой", то есть для "своих нужд"
# и его преобразовывать не надо.
        else {
            $set_own = 1;
        }

        $this->agi->verbose(
"$peername have to set CallerID to \'$callerid\' while calling to $exten",
            3
        );
        $this->log( "info",
"$peername have to set CallerID to \'$callerid\' while calling to $exten"
        );

        unless ( defined($set_own) ) {

# Если не меняли номер на свой, а требуется его обрезать до национальго формата,
# для удобства набора, то проводим такую операцию.
# Конфиг-> telephony->local_country_code + local_number_length
            $callerid = $this->_cut_local_callerid($callerid);
        }

        $this->agi->exec( "Set", "CALLERID(all)=$callerid" );
    }
    else {
        unless ( defined($set_own) ) {

            # Esli my ne menyali nomer na svoj. To obrezaem do 10 cyfr.
            $callerid = $this->agi->get_variable("CALLERID(num)");
            $callerid = $this->_cut_the_plus($callerid);
            $callerid = $this->_cut_local_callerid($callerid);
            $this->agi->exec( "Set", "CALLERID(all)=$callerid" );
        }
        $this->agi->verbose( "$peername does not change own CallerID", 3 );
        $this->log( "info", "$peername does not change own CallerID" );
    }

    $this->dbh->commit();
    return;

}

=item B<cut_the_lineX(string)>

 Вырезает из строки вида LINE %d CALLERID собственно сам CALLERID. 
 Такая ситуация возникает, в следующем случае:
 1. звонок пришел на шлюз, оригинальный номер А хранится в CALLERID(name);
 2. устанавливается callerid(num) = callerid(name);
 3. при слепом транфере снова вызывается этот скрипт и снова пытается из-за имени канала 
    поменять name на num. Но при этом Name уже = LINE X CALLERID.  
    Так что нам придется вытащить его оттуда и установить в all(num);

=cut 

sub _cut_the_lineX {
    my $this = shift;
    my $str  = shift;

    $this->log( "info", "_cut_the_linex: $str" );
    if ( $str =~ /^LINE/ ) {
        my ( $line, $linex, $callerid ) = split( ' ', $str );
        return $callerid;
    }
    return $str;
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

    $this->log( "info", "_cut_local_callerid: $callerid" );

    my $local_country_code  = undef;
    my $local_number_length = undef;

    unless ( defined( $this->conf->{'telephony'}->{'local_country_code'} ) ) {
        $local_country_code = 'NULL';
    }
    else {
        $local_country_code =
          $this->conf->{'telephony'}->{'local_country_code'};
    }

    unless ( defined( $this->conf->{'telephony'}->{'local_number_length'} ) ) {
        $local_number_length = 10;
    }
    else {
        $local_number_length =
          $this->conf->{'telephony'}->{'local_number_length'};
    }

    my $calleridlen = length($callerid);
    if ( $calleridlen > $local_number_length ) {

# Длина входящего номера больше чем длина национального,
# Значит будем обрезать.
        if ( $callerid =~ /^$local_country_code/ ) {

# Еще и попал под regexp с началом номера с национального кода ?
# Точно будем обрезать
            $callerid = substr( $callerid, $calleridlen - $local_number_length,
                $local_number_length );
            $this->log( "info", "_cut_local_callerid: $callerid" );
        }
    }

    return $callerid;
}

# Поиск роутинга для канала Local
sub _get_local_route { 
    my $this = shift; 
    my $exten = shift; 
    my $try = shift; 

    $this->dbh->begin_work or die $this->dbh->errstr; 
    my $sth = $this->dbh->prepare("select * from routing.get_dial_route5 (?,?)");
    eval { my $rv = $sth->execute( $exten, $try ); };
    if ($@) {
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Playback", "pearlpbx-nomorelines" );
        $this->agi->exec( "Hangup",   "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    $this->dbh->commit();
    return $result;

}

sub _get_dial_route {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;
    my $try      = shift;

    $this->dbh->begin_work or die $this->dbh->errstr;
    my $sth =
      $this->dbh->prepare("select * from routing.get_dial_route4 (?,?,?)");
    eval { my $rv = $sth->execute( $peername, $exten, $try ); };
    if ($@) {
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Playback", "pearlpbx-nomorelines" );
        $this->agi->exec( "Hangup",   "17" );
        exit(-1);
    }
    my $result = $sth->fetchrow_hashref;
    $this->dbh->commit();
    return $result;

}

sub _convert_extension {
    my $this  = shift;
    my $input = shift;

    my $output = $input;
    my $result = undef;

    my $sth = $this->dbh->prepare(
"select id,exten,operation,parameters,step from routing.convert_exten where ? ~ exten order by id,step"
    );
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

    $cdr_start =~ /(\d{4})-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})/;

    my $year = $1;
    my $mon  = $2;
    my $day  = $3;
    my $hour = $4;
    my $min  = $5;
    my $sec  = $6;

    my $directory =
      sprintf( "/var/spool/asterisk/monitor/%s/%s/%s", $year, $mon, $day );

    my $filename = sprintf( "%s/%s/%s/%s%s%s-%s.wav",
        $year, $mon, $day, $hour, $min, $sec, $callerid_num );

    return ( $directory, $filename );

}

sub _init_mixmonitor {
    my $this = shift;

    my $cdr_start    = $this->agi->get_variable('CDR(start)');
    my $callerid_num = $this->agi->get_variable('CALLERID(num)');
    my ( $directory, $filename ) =
      $this->_mixmonitor_filename( $cdr_start, $callerid_num );

    mkpath($directory);

    if ( $this->{'exten'} > 0 ) {
        $this->agi->exec( "MixMonitor", "$filename" );
    }
    else {
        $this->agi->verbose(
            "This channel going to park. We do not Monitor it.");
    }

    $this->agi->verbose("CallerID(num)+CDR(start)=$callerid_num $cdr_start");
    $this->_init_uline( $callerid_num, $cdr_start );

    if ( length( $this->{'exten'} ) < 4 ) {
        if ( ( $this->{'exten'} > 0 ) and ( $this->{'exten'} < 200 ) ) {
            $this->_add_next_recording( $callerid_num, $cdr_start,
                $this->{'exten'} );
        }
    }

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

sub _uline_by_channel {
    my $this    = shift;
    my $channel = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
"select id from integration.ulines where channel_name = ? and status = 'busy'"
    );
    eval { my $rc = $sth->execute($channel); };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }

    my $result = $sth->fetchrow_hashref;
    if ( defined($result) ) {

        # There will be a dragons
        my $uline = $result->{'id'};
        $this->agi->verbose( "EXIST ULINE=$uline", 3 );
        $this->agi->set_variable( 'PARKINGEXTEN', "$uline" );
        eval { $this->dbh->commit; };
        if ($@) {
            $this->_exit( $this->dbh->errstr );
        }

        return $uline;
    }

    $this->dbh->rollback;
    return undef;
}

sub _uline_by_userfield_and_start {
    my $this      = shift;
    my $userfield = shift;
    my $cdr_start = shift;

    $this->_begin;
    my $sth = $this->dbh->prepare(
"select id from integration.ulines where id = ? and cdr_start = ? and status = 'busy'"
    );
    eval { my $rv = $sth->execute( $userfield, $cdr_start ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->dbh->rollback;
        return undef;
    }
    my $uline = $result->{'id'};
    $this->agi->verbose( "EXIST USERFIELD ULINE=$uline", 3 );
    $this->agi->set_variable( 'PARKINGEXTEN', "$uline" );
    eval { $this->dbh->commit; };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    return $uline;
}

sub _add_new_recording {
    my $this         = shift;
    my $callerid_num = shift;
    my $cdr_start    = shift;
    my $uline        = shift;

    my $cdr_src = $this->agi->get_variable('CDR(src)');
    my $cdr_dst = $this->agi->get_variable('CDR(dst)');

    $this->_begin;
    my $sth = $this->dbh->prepare(
"insert into integration.recordings (uline_id,original_file,cdr_start,cdr_src,cdr_dst) values (?,?,?,?,?) returning id"
    );
    my ( $directory, $original_file ) =
      $this->_mixmonitor_filename( $cdr_start, $callerid_num );
    eval {
        my $rv =
          $sth->execute( $uline, $original_file, $cdr_start, $cdr_src,
            $cdr_dst );
    };

    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    my $new_id = $result->{'id'};
    $this->dbh->commit;

    $this->agi->verbose(
        "Added new recording to uline $uline with $cdr_start and $callerid_num",
        3
    );
    $this->log( "info",
        "Added new recording to uline $uline with $cdr_start and $callerid_num"
    );

    return undef;
}

sub _add_next_recording {
    my $this         = shift;
    my $callerid_num = shift;
    my $cdr_start    = shift;
    my $uline        = shift;

    $this->agi->verbose(
        "Add next recording: '$callerid_num' '$cdr_start' '$uline'", 3 );

    my $cdr_src = $this->agi->get_variable('CDR(src)');
    my $cdr_dst = $this->agi->get_variable('CDR(dst)');

    $this->_begin;
    my $sth = $this->dbh->prepare(
"select id from integration.recordings where uline_id=? and next_record is NULL order by id desc limit 1"
    );
    eval { my $rv = $sth->execute($uline); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {

        #$this->_exit(
        #    "EXCEPTION: ADDING NEXT RECORD TO NULL. CALL THE LOCKSMAN.")
        $this->dbh->rollback();
        return;
    }
    my $id = $result->{'id'};

    $sth = $this->dbh->prepare(
"insert into integration.recordings (uline_id,original_file,previous_record,cdr_start,cdr_src,cdr_dst) values (?,?,?,?,?,?) returning id"
    );
    my ( $directory, $original_file ) =
      $this->_mixmonitor_filename( $cdr_start, $callerid_num );
    eval {
        my $rv =
          $sth->execute( $uline, $original_file, $id, $cdr_start, $cdr_src,
            $cdr_dst );
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $result = $sth->fetchrow_hashref;
    my $new_id = $result->{'id'};

    eval {
        $this->dbh->do(
            "update integration.recordings set next_record=$new_id where id=$id"
        );
    };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
}

sub _update_uline_by_new_channel {
    my $this    = shift;
    my $uline   = shift;
    my $channel = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
        "update integration.ulines set channel_name=? where id=?");
    eval { my $rv = $sth->execute( $channel, $uline ); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;
    $this->agi->verbose( "ULINE $uline updated with $channel", 3 );
    $this->log( "info", "ULINE $uline updated with $channel" );
}

sub _init_uline {
    my $this         = shift;
    my $callerid_num = shift;
    my $cdr_start    = shift;
    my $uniqueid     = $this->agi->get_variable('CDR(uniqueid)');
    my $channel      = $this->{'channel'};

    if ( $this->{debug} ) {
        $this->log( "info", "_init_uline: $callerid_num $cdr_start" );
        $this->agi->verbose( "_init_uline: $callerid_num $cdr_start", 3 );
    }

    # Try to find existing channel
    my $uline = $this->_uline_by_channel($channel);
    if ( defined($uline) ) {
        if ( $this->{'exten'} > 0 ) {
            $this->_add_next_recording( $callerid_num, $cdr_start, $uline );
        }
        return;
    }

    # Try to find by ULINE (userfield)
    my $userfield = $this->agi->get_variable("CDR(userfield)");
    if ( defined($userfield) ) {
        my $trimmed_userfield = str_trim($userfield);

        if ( $trimmed_userfield ne '' ) {

# Если userfield не пустой, тогда пытаемся что-то найти.
            if ( $this->{debug} ) {
                $this->log( "info", "current CDR(userfield)=" . $userfield );
                $this->agi->verbose( "current CDR(userfield)=" . $userfield,
                    3 );
            }

            $uline =
              $this->_uline_by_userfield_and_start( $userfield, $cdr_start );

            if ( defined($uline) ) {

              # Неужели нашли ? Обновим информацию.
                $this->_update_uline_by_new_channel( $uline, $channel );

# Если мы звоним не на парковку, то дополняем запись.
                if ( $this->{'exten'} > 0 ) {
                    $this->_add_next_recording( $callerid_num, $cdr_start,
                        $uline );
                }
                return;
            }
        }
    }

    # Create new uline
    $this->agi->verbose( "Create new ULINE", 3 );
    $this->log( "info", "Create new ULINE" );
    $this->_begin;

    my $sth =
      $this->dbh->prepare("select * from integration.get_free_uline();");

    eval { my $rv = $sth->execute; };
    if ($@) {

        # raised exception
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }

    my $result = $sth->fetchrow_hashref;
    $uline = $result->{'get_free_uline'};

    $this->agi->verbose( "ULINE=$uline", 3 );
    $this->log( "info", "ULINE=$uline" );

    $this->agi->set_variable( "PARKINGEXTEN",   "$uline" );
    $this->agi->set_variable( "CDR(userfield)", "$uline" );
    $this->agi->set_variable( "ULINE",          "$uline" );

    my $caller_name = $this->_get_callername($callerid_num);
    unless ( defined($caller_name) ) {

        $this->agi->exec( "Set", "CALLERID(name)=LINE $uline $callerid_num" );
        $this->log( "info", "CALLERID(name)=LINE $uline $callerid_num" );

    }
    else {

        $this->agi->exec( "Set",
            "CALLERID(name)=LINE $uline $caller_name $callerid_num" );
        $this->log( "info",
            "CALLERID(name)=LINE $uline $caller_name $callerid_num" );

    }

    $sth = $this->dbh->prepare(
"update integration.ulines set status='busy',callerid_num=?,cdr_start=?,channel_name=?,uniqueid=? where id=?"
    );
    eval {
        my $rv =
          $sth->execute( $callerid_num, $cdr_start, $channel, $uniqueid,
            $uline );
    };

    if ($@) {
        $this->log( "warning", $this->dbh->errstr );
        $this->agi->verbose( $this->dbh->errstr, 3 );
        $this->agi->exec( "Hangup", "17" );
        exit(-1);
    }
    $this->dbh->commit;

    $this->_add_new_recording( $callerid_num, $cdr_start, $uline );

}

sub _get_callername {
    my ( $this, $callerid ) = @_;

    my $sql = "select comment from public.sip_peers where name=?";
    my $adr = "select displayname from ivr.addressbook where msisdn=?";

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

sub process {
    my $this = shift;

    my $channel   = $ARGV[0];
    my $extension = $ARGV[1];

    my $dialstatus = undef;

    $this->{'channel'} = $channel;
    $this->{'exten'}   = $extension;

    # split the channel name

    ( $this->{proto}, $this->{peername}, $this->{channel_number} ) = $this->_cutoff_channel($channel);

    $this->{channel}   = $channel;
    $this->{extension} = $extension;

    # Set timeout(absolute)
    $this->agi->set_variable( "TIMEOUT(absolute)", "3600" );

    # Connect to the database
    $this->_db_connect();

    # Установка номера А. Если используется канал Local, то эта функция игнорируется. 
    if ( $this->{proto} ne "Local" ) { 
        $this->_get_callerid( $this->{peername}, $this->{extension} ) 
    } 

    # Init MixMonitor
    $this->_init_mixmonitor();

    # Проверка прав доступа.  Если используется канал "Local", то эта функция игнорируется.
    if ( $this->{proto} ne "Local") { 
        $this->_get_permissions( $this->{peername}, $this->{extension} );
    } 

    # Convert extension
    $extension = $this->_convert_extension( $this->{'extension'} );

    my $tgrp_first;

    # Get dial route
    for ( my $current_try = 1 ; $current_try <= 5 ; $current_try++ ) {
        $this->agi->verbose(
            "Call _get_dial_route("
              . $this->{peername} . ","
              . $this->{extension} . ","
              . $current_try . ")",
            3
        );
        my $result = undef;  
        if ( $this->{proto} ne "Local") { 
            $result = $this->_get_dial_route( $this->{peername}, $this->{extension}, $current_try );
        } else { 
            $result = $this->_get_local_route ( $this->{extension}, $current_try ); 
        } 
        unless ( defined($result) ) {
            $this->log( "warning",
                "SOMETHING WRONG. _get_dial_route returns undefined value." );
            $this->agi->verbose(
                "SOMETHING WRONG!  _get_dial_route returns undefined value.",
                3 );
            die "SOMETHING WRONG!  _get_dial_route returns undefined value.";
        }

        my $dst_str  = $result->{'dst_str'};
        my $dst_type = $result->{'dst_type'};
        $current_try = $result->{'try'};
        $this->agi->verbose(
            "dst_str=$dst_str,dst_type=$dst_type,try=$current_try", 3 );
        my $res = undef;

        if ( ( $dst_type eq "user" ) or ( $dst_type eq "lmask" ) ) {
            $this->agi->verbose( "Dial SIP/$dst_str", 3 );
            $res = $this->agi->exec( "Dial", "SIP/$dst_str,120,mtT" );
            $this->agi->verbose( "result = $res", 3 );
            $dialstatus = $this->agi->get_variable("DIALSTATUS");
            $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
            if ( $dialstatus =~ /^ANSWER/ ) {
                exit(0);
            }
            if ( $dialstatus =~ /^BUSY/ ) {
		        $this->agi->exec( "Busy", "5"); 
                $this->agi->exec( "Hangup", "17" );
                exit(0);
            }
        }
        if ( $dst_type eq "trunk" ) {
            $this->agi->verbose( "Dial SIP/$dst_str/$extension", 3 );
            $res =
              $this->agi->exec( "Dial", "SIP/$dst_str/$extension,120,tTg" );
            $this->agi->verbose( "result = $res", 3 );
            $dialstatus = $this->agi->get_variable("DIALSTATUS");
            $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
            if ( $dialstatus =~ /^ANSWER/ ) {
                exit(0);
            }
            if ( $dialstatus =~ /^BUSY/ ) {
		$this->agi->exec( "Busy", "5");
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
                $res =
                  $this->agi->exec( "Dial", "SIP/$dst_str/$extension,120,tTg" );
                $this->agi->verbose( "result = $res", 3 );
                $dialstatus = $this->agi->get_variable("DIALSTATUS");
                $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
                if ( $dialstatus =~ /^ANSWER/ ) {
                    exit(0);
                }
                if ( $dialstatus =~ /^BUSY/ ) {
		    $this->agi->exec( "Busy", "5");
                    $this->agi->exec( "Hangup", "17" );
                    exit(0);
                }
                next;
            }
            if ( $dst_str eq $tgrp_first ) {
                $current_try = $current_try + 1;
                $tgrp_first  = undef;
                $this->agi->verbose(
                    "$dst_str = $tgrp_first. current_try++ = $current_try", 3 );
                next;
            }
            $this->agi->verbose("current_try = $current_try");
            $res =
              $this->agi->exec( "Dial", "SIP/$dst_str/$extension,120,tTg" );
            $this->agi->verbose( "result = $res", 3 );
            $dialstatus = $this->agi->get_variable("DIALSTATUS");
            $this->agi->verbose( "DIALSTATUS=" . $dialstatus, 3 );
            if ( $dialstatus =~ /^ANSWER/ ) {
                exit(0);
            }
            if ( $dialstatus =~ /^BUSY/ ) {
		$this->agi->exec( "Busy", "5");
                $this->agi->exec( "Hangup", "17" );
                exit(0);
            }

        }    # End of (if tgrp)

    }    # End of for (1...5)
    #$this->agi->exec( "Playback", "pearlpbx-nomorelines" );
    $this->agi->exec( "Busy", "5");

}    # End of process();

#===============================================================================

__END__

=head1 NAME

NetSDS-route.pl

=head1 SYNOPSIS

NetSDS-route.pl

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

