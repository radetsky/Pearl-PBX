#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  import_blacklist.pl
#
#  DESCRIPTION:  Копирует из результатов запроса в MySQL значения в локальный черный список. 
#                Сделано для Радиогруппы 13 мая 2015 года. 
#        NOTES:  Запускается по крону. Не демонизируется. 
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  13.05.2015
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

use constant MyDSN => 'DBI:mysql:database=radiowinners;host=winners.umh.com.ua';
use constant MyUser => 'pbxwinners'; 
use constant MyPass => 'zeyq8AUNUeY'; 

use constant PgSQL1 => "select * from public.blacklist where number=?"; # Ищем, а нет ли тут уже этого номера 
use constant PgSQL2 => "insert into public.blacklist ( number, reason ) values ( ?, ? )"; 
use constant MySQL1 => "SELECT wl.id, wl.phone FROM winnersList wl LEFT JOIN blocked bl ON wl.id = bl.winnerID WHERE blockUntill"; 

# Init 
init();
my $pgdbh = connect_pgsql(); 
my $mydbh = connect_mysql();  

write_pgsql($pgdbh, read_mysql($mydbh) ); 

sub read_mysql { 
	my ($mydbh) = @_; 

	my $sth = $mydbh->prepare_cached(MySQL1); 
	eval { $sth->execute(); };  
	if ( $@ ) { die $mydbh->errstr; }
	my $result = $sth->fetchall_hashref('id'); 
	return $result; 
}

sub write_pgsql { 
	my ($pgdbh, $result) = @_; 

	my $sth1 = $pgdbh->prepare_cached(PgSQL1); 
	my $sth2 = $pgdbh->prepare_cached(PgSQL2); 

	foreach my $item ( keys %{ $result } ) { 
		my $phone = $result->{$item}->{'phone'}; 
		eval { $sth1->execute($phone); }; 
		if ( $@ ) { die $pgdbh->errstr; }
		my $result = $sth1->fetchrow_hashref(); 
		unless ( defined ( $result )) { 
			eval { $sth2->execute($phone, "Imported from winners.umh.com.ua"); };
			if ( $@ ) { die $pgdbh->errstr; }
			print "Imported $phone\n"; 
		} else { 
			print "$phone already here.\n"; 
		}

	}

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
