#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  pgsql2mysql.pl
#
#  DESCRIPTION:  Копирует статистику их PostgreSQL в MySQL. Только не спрашивайте зачем :) 
#        NOTES:  Запускается по крону. Не демонизируется. 
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  23.08.2014 17:13:03 EEST
#===============================================================================
use 5.8.0; 
use strict; 
use warnings; 

use DBI; 
use Data::Dumper; 
use Proc::PID::File;
use POSIX;  

use constant PgDSN => 'dbi:Pg:dbname=asterisk;host=localhost'; 
use constant PgUser => 'asterisk'; 
use constant PgPass => 'supersecret'; 

use constant MyDSN => 'DBI:mysql:database=cityNE;host=89.184.70.76';
use constant MyUser => 'u_cityofficeusr1'; 
use constant MyPass => 'Zfnch15C3D1aAp'; 

use constant PgSQL1 => "select * from cdr";
use constant PgSQL2 => "select * from queue_log"; 
use constant PgSQL3 => "select * from queue_parsed"; 

use constant MySQL1 => "insert into asterisk_cdr ( calldate, clid, src, dst, dcontext, lastapp, lastdata, duration, billsec, disposition, channel, dstchannel, amaflags, accountcode, uniqueid) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "; 

use constant MySQL2 => "insert into asterisk_queue_log ( callid, queuename, agent, event, data, time ) values ( ?, ?, ?, ?, ?, ?)"; 
use constant MySQL3 => "insert into asterisk_queue_parsed ( callid, queue, time, callerid, agentid, status, success, holdtime, calltime, position ) values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"; 

use constant LastIdFile => "/etc/PearlPBX/pgsql2mysql.conf"; 
use constant PORTION => 100; 

# Init 
init();
my $pgdbh = connect_pgsql(); 
my $mydbh = connect_mysql();  
my ( $id_cdr, $id_queue_log, $id_queue_parsed ) =  read_last_id(); 

unless ( defined ( $id_cdr )) { 
	lets_begin($pgdbh, $mydbh); 
} else { 
	lets_continue( $pgdbh, $mydbh, $id_cdr, $id_queue_log, $id_queue_parsed); 
}

sub lets_begin { 
	my ( $pgdbh, $mydbh) = @_; 

	my $id_cdr = begin_cdr($pgdbh, $mydbh); 
	my $id_queue_log = begin_queue_log($pgdbh, $mydbh); 
	my $id_queue_parsed = begin_queue_parsed($pgdbh, $mydbh); 

	save_last_id ( $id_cdr, $id_queue_log, $id_queue_parsed); 
	exit(0); 
}

sub lets_continue { 
	my ( $pgdbh, $mydbh, $id_cdr, $id_queue_log, $id_queue_parsed) = @_; 

	my $id_cdr2          = continue_cdr ($pgdbh, $mydbh, $id_cdr); 
	my $id_queue_log2    = continue_queue_log ($pgdbh, $mydbh, $id_queue_log); 
	my $id_queue_parsed2 = continue_queue_parsed ( $pgdbh, $mydbh, $id_queue_parsed); 

	save_last_id ( $id_cdr2, $id_queue_log2, $id_queue_parsed2); 
	exit (0); 

}

sub begin_cdr { 
	my ( $pgdbh, $mydbh) = @_; 


	my $offset = 0; 
	my $last_id = undef; 
	while (1) { 
		printf("%s select %d records from CDR...", printtime(), PORTION); 

		my $pgsth1 = $pgdbh->prepare_cached (PgSQL1 . " order by calldate asc limit ".PORTION." offset $offset"); 
		eval { $pgsth1->execute(); }; 
		if ( $@ ) { 
			die $pgdbh->errstr; 
		}
		my $result = $pgsth1->fetchall_hashref ( 'calldate' ); 
		printf("Ok. %d\n", scalar(keys(%{$result}))); 
		unless ( $result ) { 
			unless ( defined ( $last_id)) { return undef; }
			return $last_id; 
		}  

		$last_id = last_key ($result); 
		mysql_insert_cdr($mydbh, $result); 
		$offset = $offset + PORTION; 
	}

}

sub continue_cdr { 
	my ( $pgdbh, $mydbh, $id_cdr) = @_; 

	my $offset = 0; 
	my $last_id = undef; 
	while (1) { 
		printf("%s select %d records from CDR...", printtime(), PORTION); 

		my $pgsth1 = $pgdbh->prepare_cached (PgSQL1 . " where calldate > '".$id_cdr."' order by calldate asc limit ".PORTION." offset $offset"); 
		eval { $pgsth1->execute(); }; 
		if ( $@ ) { 
			die $pgdbh->errstr; 
		}
		my $result = $pgsth1->fetchall_hashref ( 'calldate' ); 
		printf("Ok. %d\n", scalar(keys(%{$result}))); 
		unless ( $result ) { 
			unless ( defined ( $last_id)) { return undef; }
			return $last_id; 
		}  

		$last_id = last_key ($result); 
		mysql_insert_cdr($mydbh, $result); 
		$offset = $offset + PORTION; 
	}

}

sub begin_queue_log { 
	my ( $pgdbh, $mydbh) = @_; 
	my $offset = 0; 
	my $last_id = undef; 
	while (1) { 
		printf("%s select %d records from CDR...", printtime(), PORTION); 

		my $pgsth1 = $pgdbh->prepare_cached (PgSQL2 . " order by id asc limit ".PORTION." offset $offset"); 
		eval { $pgsth1->execute(); }; 
		if ( $@ ) { 
			die $pgdbh->errstr; 
		}
		my $result = $pgsth1->fetchall_hashref ( 'id' ); 
		printf("Ok. %d\n",scalar(keys(%{$result}))); 

		unless ( $result ) { 
			unless ( defined ( $last_id)) { return undef; }
			return $last_id; 
		}  
		$last_id = last_key ($result); 
		mysql_insert_queue_log($mydbh, $result); 
		$offset = $offset + PORTION; 
	}
}
sub continue_queue_log { 
	my ( $pgdbh, $mydbh, $id) = @_; 
	my $offset = 0; 
	my $last_id = undef; 
	while (1) { 
		printf("%s select %d records from CDR...", printtime(), PORTION); 

		my $pgsth1 = $pgdbh->prepare_cached (PgSQL2 . " where id > ".$id." order by id asc limit ".PORTION." offset $offset"); 
		eval { $pgsth1->execute(); }; 
		if ( $@ ) { 
			die $pgdbh->errstr; 
		}
		my $result = $pgsth1->fetchall_hashref ( 'id' ); 
		printf("Ok. %d\n",scalar(keys(%{$result}))); 

		unless ( $result ) { 
			unless ( defined ( $last_id)) { return undef; }
			return $last_id; 
		}  
		$last_id = last_key ($result); 
		mysql_insert_queue_log($mydbh, $result); 
		$offset = $offset + PORTION; 
	}
}

sub begin_queue_parsed { 
	my ( $pgdbh, $mydbh) = @_; 
	my $offset = 0; 
	my $last_id = undef; 
	while (1) { 
		printf("%s select %d records from CDR...", printtime(), PORTION); 

		my $pgsth1 = $pgdbh->prepare_cached (PgSQL3 . " order by id asc limit ".PORTION." offset $offset"); 
		eval { $pgsth1->execute(); }; 
		if ( $@ ) { 
			die $pgdbh->errstr; 
		}
		my $result = $pgsth1->fetchall_hashref ( 'id' );
		printf("Ok. %d\n",scalar(keys(%{$result})));  
		unless ( $result ) { 
			unless ( defined ( $last_id)) { return undef; }
			return $last_id; 
		}  
		$last_id = last_key ($result); 
		mysql_insert_queue_parsed($mydbh, $result); 
		$offset = $offset + PORTION; 
	}
}

sub continue_queue_parsed { 
	my ( $pgdbh, $mydbh, $id) = @_; 
	my $offset = 0; 
	my $last_id = undef; 
	while (1) { 
		printf("%s select %d records from CDR...", printtime(), PORTION); 

		my $pgsth1 = $pgdbh->prepare_cached (PgSQL3 . " where id > ".$id." order by id asc limit ".PORTION." offset $offset"); 
		eval { $pgsth1->execute(); }; 
		if ( $@ ) { 
			die $pgdbh->errstr; 
		}
		my $result = $pgsth1->fetchall_hashref ( 'id' );
		printf("Ok. %d\n",scalar(keys(%{$result})));  
		unless ( $result ) { 
			unless ( defined ( $last_id)) { return undef; }
			return $last_id; 
		}  
		$last_id = last_key ($result); 
		mysql_insert_queue_parsed($mydbh, $result); 
		$offset = $offset + PORTION; 
	}
}

sub last_key { 
	my ($hash_ref) = @_; 
	return undef unless $hash_ref; 

	my @keys = sort keys %{$hash_ref}; 
	return pop @keys; 
}


sub mysql_insert_cdr { 
	my ($mydbh, $hash_ref) = @_; 

	printf("%s Insert %d records to CDR...", printtime(), scalar(keys %{$hash_ref}) ); 
	$mydbh->begin_work; 

	my $mysth1 = $mydbh->prepare_cached ( MySQL1 ); 
	foreach my $key ( keys %{$hash_ref} ) { 
		eval { $mysth1->execute ( 
			$hash_ref->{$key}->{'calldate'}, 
			$hash_ref->{$key}->{'clid'}, 
			$hash_ref->{$key}->{'src'}, 
			$hash_ref->{$key}->{'dst'}, 
			$hash_ref->{$key}->{'dcontext'},
			$hash_ref->{$key}->{'lastapp'}, 
			$hash_ref->{$key}->{'lastdata'}, 
			$hash_ref->{$key}->{'duration'}, 
			$hash_ref->{$key}->{'billsec'}, 
			$hash_ref->{$key}->{'disposition'}, 
			$hash_ref->{$key}->{'channel'}, 
			$hash_ref->{$key}->{'dstchannel'}, 
			$hash_ref->{$key}->{'amaflags'}, 
			$hash_ref->{$key}->{'accountcode'}, 
			$hash_ref->{$key}->{'uniqueid'}  
		); }; 
		if ( $@ ) { 
			die $@ . "\n" . $mydbh->errstr . "\n";  
		}
	}
	$mydbh->commit; 
	printf("Ok.\n"); 
}

sub mysql_insert_queue_log { 
	my ($mydbh, $hash_ref) = @_; 

	printf("%s Insert %d records to Queue Log...", printtime(), scalar(keys %{$hash_ref}) ); 
	$mydbh->begin_work;
	my $mysth1 = $mydbh->prepare_cached ( MySQL2 ); 
	foreach my $key ( keys %{$hash_ref} ) { 
		eval { $mysth1->execute ( 
			$hash_ref->{$key}->{'callid'}, 
			$hash_ref->{$key}->{'queuename'}, 
			$hash_ref->{$key}->{'agent'}, 
			$hash_ref->{$key}->{'event'}, 
			$hash_ref->{$key}->{'data'}, 
			$hash_ref->{$key}->{'time'} 
		); }; 
		if ( $@ ) { 
			die $@ . "\n" . $mydbh->errstr . "\n";  
		}
	}
	$mydbh->commit; 
	printf("Ok\n"); 
}

sub mysql_insert_queue_parsed { 
	my ($mydbh, $hash_ref) = @_; 

	printf("%s Insert %d records to Queue Parsed Log...", printtime(), scalar(keys %{$hash_ref}) ); 
	$mydbh->begin_work;
	my $mysth1 = $mydbh->prepare_cached ( MySQL3 ); 
	foreach my $key ( keys %{$hash_ref} ) { 
		eval { $mysth1->execute ( 
			$hash_ref->{$key}->{'callid'}, 
			$hash_ref->{$key}->{'queue'},
			$hash_ref->{$key}->{'time'}, 
			$hash_ref->{$key}->{'callerid'},
			$hash_ref->{$key}->{'agentid'}, 
			$hash_ref->{$key}->{'status'}, 
			$hash_ref->{$key}->{'success'},
			$hash_ref->{$key}->{'holdtime'},
			$hash_ref->{$key}->{'calltime'},
			$hash_ref->{$key}->{'position'}
		); }; 
		if ( $@ ) { 
			die $@ . "\n" . $mydbh->errstr . "\n";  
		}
	}
	$mydbh->commit; 
	printf("Ok\n"); 
}

sub printtime { 
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	return strftime ("%F %T", $sec, $min, $hour, $mday, $mon, $year); 

}

sub save_last_id { 
	my ($id_cdr, $id_queue_log, $id_queue_parsed) = @_; 
	open (my $conf, ">", LastIdFile) or die "Can't open " . LastIdFile . "for write: $!\n"; 
	print $conf $id_cdr . ";" . $id_queue_log . ";" . $id_queue_parsed . "\n"; 
	close $conf; 
}

sub read_last_id { 
	open ( my $conf, "<", LastIdFile ) or die "Can't open " . LastIdFile . ": $!\n"; 
	my $line = <$conf>;
	unless ( defined ( $line ) ) {
		close $conf;  
		return (undef, undef, undef); 
	} 
	chomp $line; 
	my ( $id1, $id2, $id3 ) = split (";", $line); 
	close $conf; 
	return $id1, $id2, $id3; 
}

sub connect_pgsql { 

	my $dbh = DBI->connect_cached ( PgDSN, PgUser, PgPass , { RaiseError => 1, AutoCommit =>1 } ); 
  	unless ( defined ( $dbh ) ) { 
    	die "Can't connect to ". PgDSN . ": $!\n"; 
  	}

	return $dbh; 
}

sub connect_mysql { 

	my $dbh = DBI->connect_cached ( MyDSN, MyUser, MyPass , { RaiseError => 1, AutoCommit =>1, mysql_auto_reconnect=>1 } ); 
  	unless ( defined ( $dbh ) ) { 
    	die "Can't connect to ". MyDSN . ": $!\n"; 
  	}

	return $dbh; 
}


sub init { 

	if ( Proc::PID::File->running ( dir => '/var/run', name => 'pgsql2mysql' ) ) {
    	die "Application already running, stop immediately!";
  	}

}
