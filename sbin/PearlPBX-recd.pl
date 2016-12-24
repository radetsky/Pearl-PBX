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


sub _set_result_file { 
	my $this = shift; 
	my $record_id = shift; 
	my $result_file = shift; 

	my $sth = $this->dbh->prepare ("update integration.recordings set result_file=? , concatenated=true, mp3=true where id=?");
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

	my $sth = $this->dbh->prepare ("update integration.recordings set concatenated=true, mp3=true, result_file='FAULT' where id=?"); 
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
sub _compare_two_timestamps_for_hour { 
    my ($this, $t1, $t2) = @_; 

    my $sth2 = $this->dbh->prepare(
        "select (?::timestamp - ?::timestamp) > '01:00:00' as interval"); 

    eval { $sth2->execute($t1,$t2); };
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    my $interval = $sth2->fetchrow_hashref; 
    if ($interval->{'interval'} == 0) {
        return undef; # Исправлять не надо.
    }
    return 1; 
}
sub _fix_very_old_talks { 
    my $this = shift; 
    my $current_record = shift; 
    my $previous_record = shift;

    # Надо на предыдущей записи поставить финальный признак и всю цепочку конвертнуть. 
    $this->speak( "Fixing WRONG LONG record between ".$current_record->{'id'}." and ".$previous_record->{'id'});

    my $sql = "update integration.recordings set next_record=0 where id=".$previous_record->{'id'};
 
    eval { $this->dbh->do($sql); }; 
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    # На текущей записи надо поставить previous_record = 0 и начать ее раскручивать.  
    $sql = "update integration.recordings set previous_record=0 where id=".$current_record->{'id'}; 
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

sub _more_than_hour_from_now { 
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
        return undef; # Исправлять не надо.
    }

    return 1; 
}

sub _find_first_unconverted { 
    my $this = shift; 

    # Prepare the query for finding 1st unconverted record in the database. 
    my $sth = $this->dbh->prepare(
        "select * from integration.recordings where mp3=false and finished=true order by id asc limit 1 for update"
    );

    # Execute it. 
    eval { $sth->execute(); };
    if ( $@ ) {
        $this->_exit( $this->dbh->errstr );
    }

    # Fetch only one row ! 
    my $result = $sth->fetchrow_hashref;
    unless ( defined ( $result ) ) {
        $this->_exit("Can't find 1st unconverted record! ");
    }

    return $result; 
}

sub _update_record_set_next_to_zero { 
    my ($this, $record) = @_; 
    my $sql = "update integration.recordings set next_record=0 where id=".$record->{'id'}; 
    eval { $this->dbh->do($sql); }; 
    if ($@) {
        $this->dbh->rollback;
        $this->log("warning",$this->dbh->errstr);
        return undef; 
    }
    $this->dbh->commit;
    return 1; 
}

sub process {
    my $this = shift;

    $this->_begin;
	
    my $result = $this->_find_first_unconverted; 
	
    # Analyze fetched row 
	my $id            = $result->{'id'};
    my $original_file = $result->{'original_file'};
    $this->speak("Got ID=$id FILE=$original_file");

	my $result_file = $original_file; 
	$result_file =~ s{\.[^.]+$}{};    # removes extension
	$result_file = $result_file . ".mp3";
	my $infile  = "/var/spool/asterisk/monitor/" . $original_file; 
    my $outfile = "/var/spool/asterisk/monitor/" . $result_file;

    my $strlog = "/usr/bin/sox $infile to $outfile"; 
    $this->log("info",$strlog);
	my $rc = exec_external ('/usr/bin/sox',$infile,'-t','mp3','-c','2','-r','8000',$outfile); 

	unless ( defined ( $rc ) ) { 
	    $this->_convert_fault($id);
		$this->dbh->commit;
		$this->log("info","Can't convert $infile to $outfile"); 
		$this->speak("Can't convert $infile to $outfile"); 
		return 1; 
	}

	$this->_set_result_file ( $id, $result_file ); 	
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

