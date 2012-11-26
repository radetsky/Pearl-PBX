#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-recd.pl
#
#        USAGE:  ./PearlPBX-recd.pl [ --verbose ]
#
#  DESCRIPTION:  Find and converts sound files
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Radetsky 
#      VERSION:  1.0
#      CREATED:  12/31/11 09:44:14 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

PearlPBXRecd->run(
    daemon      => undef,
    verbose     => 0,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => 1,
);

1;

package PearlPBXRecd;

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use Data::Dumper;
use NetSDS::Util::File;

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

    $this->{'bad_id'} = 0; 

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

    $this->log("warning", $errstr );
		$this->speak ($errstr); 
    exit(-1);
}

sub _get_next_record {
    my $this       = shift;
    my $current_id = shift;

    # remember - transaction already began;
    my $sth = $this->dbh->prepare(
        "select * from integration.recordings where next_record=?");
    eval { $sth->execute($current_id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    return $result;
}

sub _get_record_by_previous_id {

    my $this       = shift;
    my $current_id = shift;

    # remember - transaction already began;
    my $sth = $this->dbh->prepare(
        "select * from integration.recordings where previous_record=? and next_record is null and cdr_start < now() - '1 day'::interval order by id limit 1");
    eval { $sth->execute($current_id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;
    return $result;
}

sub _fix_pseudo_active_talk { 
		my $this = shift;
		my $fail_record = shift; 

		my $id = $fail_record->{'id'}; 
		$this->log("info","Fix ID=$id set next_record=0");
		$this->speak("Fix ID=$id set next_record=0");

	  my $sth = $this->dbh->prepare(
			"update integration.recordings set next_record=0 where id=?" ); 
		eval { $sth->execute ( $id ); }; 
		if ($@) { 
				$this->_exit ( $this->dbh->errstr ); 
		}

		return 1; 
}
sub _set_result_file { 
	my $this = shift; 
	my $record_id = shift; 
	my $result_file = shift; 

	my $sth = $this->dbh->prepare ("update integration.recordings set result_file=? , concatenated=true where id=?");
	eval { $sth->execute($result_file,$record_id); }; 
	if ($@) { 
		$this->dbh->rollback;
		$this->_exit("Can't update integration.recordings to set result_file=$result_file where id=$record_id"); 
	} 
	return 1; 
}	

sub _convert_fault { 
	my $this = shift; 
	my $id = shift; 

	my $sth = $this->dbh->prepare ("update integration.recordings set concatenated=true,result_file='FAULT' where id=?"); 
    eval { $sth->execute($id); };
    if ($@) {
        $this->dbh->rollback;
        $this->_exit("Can't update integration.recordings to set result_file=FAULT where id=$id");
    }
    return 1;
}
=item B<_fix_very_old_talks> 

 Пытается исправить ошибку в работе route+hangupd. Проверяет, если цепочка между сессиями больше 1 часа,
 то цепочку разрывает. 
 Возвращает 1 в случае исправления,
 0 - если исправлять не надо, 
 undef в случае непредвиденной ошибки.

=cut 
sub _fix_very_old_talks { 
    my $this = shift; 
    my $current_id = shift; 
    my $current_cdr_start = shift; 
    my $previous_record = shift; 

    my $sql = "select * from integration.recordings where id=?"; 
    my $sth = $this->dbh->prepare ($sql);
    eval { $sth->execute($previous_record); };
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    my $prev = $sth->fetchrow_hashref; 

    my $sth2 = $this->dbh->prepare(
        "select (?::timestamp - ?::timestamp) > '01:00:00' as interval"); 
    eval { $sth2->execute($current_cdr_start,$prev->{'cdr_start'}); };
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    my $interval = $sth2->fetchrow_hashref; 
    if ($interval->{'interval'} == 0) {
        return 0; # Исправлять не надо.
    }
    # А вот теперь пытаемся исправить.
    # Надо на предыдущей записи поставить финальный признак и всю цепочку конвертнуть. 
    $this->log("warning","Try to fix WRONG LONG record between $current_id and ".$prev->{'id'});
    $this->speak( "Try to fix WRONG LONG record between $current_id and ".$prev->{'id'});

    $sql = "update integration.recordings set next_record=0 where id=".$prev->{'id'};
    warn $sql; 

    eval { $this->dbh->do($sql); }; 
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    # На текущей записи надо поставить previous_record = 0 и начать ее раскручивать.  
    $sql = "update integration.recordings set previous_record=0 where id=".$current_id;
    warn $sql; 
    eval { $this->dbh->do($sql); }; 
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    $this->dbh->commit;
    return 1; 

}

sub _is_must_be_fixed { 
    my ($this, $record) = @_; 

    my $sth2 = $this->dbh->prepare(
        "select (now()::timestamp - ?::timestamp) > '01:00:00' as interval"); 
    eval { $sth2->execute($record->{'cdr_start'}); };
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }

    my $interval = $sth2->fetchrow_hashref; 
    if ($interval->{'interval'} == 0) {
        return 0; # Исправлять не надо.
    }

    return 1; 
}

sub process {
    my $this = shift;

    my @nexts = ();

    # Find first non-converted record
    # find all files in chain
    # prepare sox string and print it

	if ($this->{'bad_id'} > 0) { 
		$this->log("info","Skipping id=".$this->{'bad_id'}." until talk is active."); 
		$this->speak("Skipping id=".$this->{'bad_id'}." until talk is active.");
	} 

	# Begin transaction
    $this->_begin;
	
	# Prepare the query for finding 1st unconverted record in the database. 
    my $sth = $this->dbh->prepare(
        "select * from integration.recordings where concatenated=false and result_file is null
			and next_record is not null and previous_record=0 and id > ? 
                order by id asc limit 1 for update"
    );

	# Execute it. 
    eval { $sth->execute ($this->{'bad_id'}); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }

    # Fetch only one row ! 
    my $result = $sth->fetchrow_hashref;
    unless ( defined($result) ) {
        $this->dbh->rollback;
        $this->_exit("No one file was found. ");
    }

	# Push the result row in some list ? WTF ! 
    push @nexts, $result;

    # Analyze fetched row 
	my $id            = $result->{'id'};
    my $uline_id      = $result->{'uline_id'};
    my $original_file = $result->{'original_file'};
    my $next_record   = $result->{'next_record'};
    my $strlog =
      "Got ID=$id ULINE=$uline_id FILE=$original_file NEXT=$next_record";
	
	# Устанавливаем в bad_id значение из поля next_record. Зачем ?
	# Это маркер активного разговора. 
	$this->{'bad_id'} = $next_record;

	# Just logging it.
	$this->log( "info", $strlog );
    $this->speak($strlog);

    if ( $next_record == 0 ) {    # First and Final record
        my $result_file = $original_file;
        $result_file =~ s{\.[^.]+$}{};    # removes extension
        $result_file = $result_file . ".mp3";
        my $infile  = "/var/spool/asterisk/monitor/" . $original_file;
        my $outfile = "/var/spool/asterisk/monitor/" . $result_file;

        my $rc = exec_external(
            "/usr/bin/sox", $infile, '-t', 'mp3',
            '-c',           '2',     '-r', '8000',
            $outfile
        );
        unless ( defined ($rc) ) {
			$this->_convert_fault($id);
            $this->dbh->commit;
	        $this->speak("Can't convert $infile into $outfile. Check the /usr/bin/sox");
	        $this->log("info","Can't convert $infile into $outfile. Check the /usr/bin/sox");
	        return 1; 
        }

        $sth = $this->dbh->prepare (
            "update integration.recordings set concatenated=true, result_file=? where id=?"
        );
        eval { $sth->execute( $result_file, $id ); };
        if ($@) {
            $this->dbh->rollback;
            $this->_exit( $this->dbh->errstr );
        }
        $this->dbh->commit;
        $this->log( "info",
            "File $original_file successfully converted to $result_file" );
        $this->speak(
            "File $original_file successfully converted to $result_file");
        return 1;
    }

    # Find the next record in the chain
    while (1) {
        my $result = $this->_get_next_record($next_record);
        unless ( defined($result) ) {
						# FIXME: Лечим баг, когда он будет закрыт, убрать этот код. 
						# Баг состоит в том, что NetSDS-route ставит next_record = текущий ID
					    # каким-то очень старым записям. Подозреваю дело в том, что hangupd не выставляет
						# в ноль (0) next_record по факту завершения звонка. Что-то я упустил. 
						# Проверить !!! FIXME! 
						my $fail_record = $this->_get_record_by_previous_id($id);
						unless ( defined ( $fail_record ) ) {
								$this->dbh->rollback;
            		             return;
						}
						# Update the recordings. set 0 to next_record and commit; 
						$this->_fix_pseudo_active_talk($fail_record);
						$this->dbh->commit;
						$this->{'bad_id'} = 0; 
						return; 

        }


        # Лечим баг с "длинными" разговорами. Проверяем разницу между записями. Если она больше часа, 
        # то разделяем цепочку. Предыдущий разговор фиксируем последним, а текущий первым в новой цепочке. 

        my $fixed = $this->_fix_very_old_talks( $result->{'id'}, 
                                                $result->{'cdr_start'},
                                                $result->{'previous_record'});
        unless ( defined ( $fixed ) ) { 
            $this->_exit("_fix_very_old_talks returns undef.");
        }

        if ($fixed == 1) { 
            return 1; 
        }

        $strlog = sprintf(
            "Got ID=%s ULINE=%s FILE=%s NEXT=%s",
            $result->{'id'},            $result->{'uline_id'},
            $result->{'original_file'}, $result->{'next_record'}
        );

		$this->{'bad_id'} = $result->{'id'}; 
        $this->log( "info", $strlog );
        $this->speak($strlog);

        push @nexts, $result;
        $id = $result->{'id'};
        $next_record = $result->{'next_record'};
		
		if ($next_record == 0) { 
		  	last; 
		} 
        unless ( defined ( $next_record ) ) { 
            # Проверяем на временной интервал. Если запись сделана давно, то фиксируем ее.  
            # Иначе пропускаем. 
            if ( $this->_is_must_be_fixed ( $result ) > 0 ) { 
                $this->_fix_pseudo_active_talk( $result );
                last; 
            } 
        }
	}

	my @infiles = ();
	my @nexts_copy = @nexts; 	

	my $result_file = undef; 
    while ( my $record = shift ( @nexts )  ) {
		my $original_file = $record->{'original_file'}; 
		unless ( defined ( $result_file ) ) { 
			$result_file = $original_file; 
			$result_file =~ s{\.[^.]+$}{};    # removes extension
	        $result_file = $result_file . ".mp3";
		}

		push @infiles, "/var/spool/asterisk/monitor/".$original_file; 

    }

    my $outfile = "/var/spool/asterisk/monitor/" . $result_file;

    $strlog = "/usr/bin/sox ".join (" ",@infiles)." to $outfile"; 
    $this->log("info",$strlog);
    #	$this->speak($strlog); 
	my $rc = exec_external ('/usr/bin/sox',@infiles,'-t','mp3','-c','2','-r','8000',$outfile); 

	unless ( defined ( $rc ) ) { 
		 while ( my $record = shift ( @nexts_copy ) ) {
			my $id = $record->{'id'};
	        $this->_convert_fault($id);
		}
		$this->dbh->commit;
		$this->log("info","Can't convert ".join (" ",@infiles)." to $outfile"); 
		$this->speak("Can't convert ".join (" ",@infiles)." to $outfile"); 
		return 1; 
		$this->_exit ("Can't convert ".join (" ",@infiles)." to $outfile"); 
	} 
	while ( my $record = shift ( @nexts_copy ) ) { 
		my $id = $record->{'id'}; 
		$this->_set_result_file ( $id, $result_file ); 	
		$this->speak("ID $id joined to $result_file"); 
	}	

    $this->dbh->commit;

}

1;

#===============================================================================

__END__

=head1 NAME

NetSDS-recd.pl

=head1 SYNOPSIS

NetSDS-recd.pl

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

