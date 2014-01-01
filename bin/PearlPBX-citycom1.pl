#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-citycom1.pl
#
#        USAGE:  ./PearlPBX-citycom1.pl 
#
#  DESCRIPTION: Раз в N дней отсылает на <email> случайный разговор операторов длительностью более чем 30 секунд из выбранных за последние N дней.  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  30.12.2013 
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

CityCom1->run(
	daemon => undef, 
	verbose => 1, 
	use_pidfile => undef, 
	has_conf => 1,
  conf_file  => "/etc/PearlPBX/asterisk-router.conf",
	infinite => undef
); 

1;

package CityCom1; 

use 5.8.0; 
use warnings; 
use strict; 

use base qw(NetSDS::App); 
use Data::Dumper; 
use DBI; 
use Getopt::Long qw(:config auto_version auto_help pass_through);
use MIME::Base64;
use NetSDS::Util::DateTime;
use MIME::Lite; 

sub start {
    my $this = shift;

    $SIG{TERM} = sub { exit(-1); };
    $SIG{INT} = sub { exit(-1);  };

    $this->mk_accessors('dbh');
    $this->_db_connect();

	  my $dayz = undef; 
		GetOptions('dayz=i' => \$dayz); 
		unless ( defined ( $dayz ) ) { 
			die "Не указан обязательный параметр --dayz.\n"; 
	 	}
		$this->{'dayz'} = $dayz; 	
	
		my $email = undef; 
		GetOptions ('email=s' => \$email); 
		unless ( defined ( $email ) ) { 
			die "Не указан обязательный параметр --email.\n"; 
	 	}
		$this->{'email'} = $email; 
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
    if ( !$this->dbh or !$this->dbh->ping ) {
        $this->dbh(
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1 } ) );
    }
    if ( !$this->dbh ) {
        $this->speak("Cant connect to DBMS!");
        $this->log( "error", "Cant connect to DBMS!" );
        exit(-1);
		}
}

sub _exit {
    my $this   = shift;
    my $errstr = shift;

    $this->speak($errstr);
    $this->log( 'warning', $errstr );

    exit(-1);
}

sub _generate_sql { 
	my ($this, $i) = @_; 

	my $sql = sprintf("select * from cdr where billsec >30 and calldate between now()-'%d days'::interval and now() and (channel like 'SIP/%d%%' or dstchannel like 'SIP/%d%%');", $this->{'dayz'},$i, $i); 
	return $sql;  
} 

sub _fetch { 
	my $this = shift; 
	my $sql = shift; 

	my $sth = $this->dbh->prepare($sql); 
	$sth->execute; 
	my $arrayref = $sth->fetchall_arrayref; 
	my @rows = @{$arrayref}; 
	my $rcount = @rows; 
	if ($rcount == 0) { 
		return (0, undef, undef);
	}
	my $rand = int(rand($rcount)); 
	my $row = $rows[$rand]; 
	my ($filename,$realfilename) = $this->_get_filename($row); 
	my $file = $this->_readfile($realfilename);
	unless ( defined ( $file ) ) { 
		return (undef,undef,undef); 
	} 
	return ($row, $filename, $realfilename);

}

sub process { 
		my $this = shift; 
		my $text = '<body><table style="border-collapse: collapse; border: 1px solid black;"><tr><th>Оператор</th><th>Кто звонил</th><th>Куда звонил</th><th>Когда</th><th>Время разговора</th><th>Приложенный файл</th></tr>'; 

		my $subject = sprintf("Случайный разговор за последние %s сутки длительностью более 30 секунд",$this->{'dayz'}); 
	  my $from       = $this->{conf}->{'email_from'};
  	unless ( defined ( $this->{conf}->{'email_from'} )) { $from = 'pearlpbx@pearlpbx.com'; }

		### Create the multipart "container":
  	my $msg = MIME::Lite->new(
        From    => $from,
        To      => $this->{'email'},
        Subject => $subject,
        Type    =>'multipart/mixed'
  	);

		for (my $i = 201; $i <= 218; $i++ ) { 
			my $sql = $this->_generate_sql($i); 
			my ($row,$filename,$realfilename);
			while ( 1 ) { 
				($row,$filename,$realfilename) = $this->_fetch($sql); 
				warn Dumper ($row,$filename,$realfilename); 	
				unless ( defined ( $row ) ) { next; }
				last; 
			}
			next if $row == 0; 
			my $newtext = $this->_make_text ($i, $row); 
			$text .= $newtext;
			$msg->attach(
        			Type        =>'audio/mpeg',
        			Path        =>$realfilename,
				Id => $filename,
        			Filename    =>$filename,
        			Disposition => 'attachment'
  			);
		}

    ### Add the text message part:
    ### (Note that "attach" has same arguments as "new"):
    $msg->attach (
        Type     =>'text/html; charset=utf-8',
        Data     => $text."</table> </body>" 
    );

    $msg->send; 

}

sub _make_text { 
	my $this = shift;
	my $operator = shift;  
	my $ar = shift; 
	my @row = @{$ar}; 
	
	my $src = $row[2]; if ( length ($src) == 9 ) { $src = '0'.$src; } 
	my $dst = $row[3]; if ( length ($dst) == 9 ) { $dst = '0'.$dst; } 
	my ($fname, $ffname ) = $this->_get_filename($ar); 
	my $url = "<a href='cid:$fname'>$fname</a>"; 

	my $body = '<tr style="border-collapse: collapse; border: 1px solid grey;">
		   <td style="border-collapse: collapse; border: 1px solid grey;">'.$operator.'</td>' .
		   '<td style="border-collapse: collapse; border: 1px solid grey;">'. $src . '</td>' .
		   '<td style="border-collapse: collapse; border: 1px solid grey;">'. $dst . '</td>' . 
		   '<td style="border-collapse: collapse; border: 1px solid grey;">'. $row[0] . '</td>'. 
		   '<td style="border-collapse: collapse; border: 1px solid grey;">'. $row[10]. ' сек. </td>' . 
		   '<td style="border-collapse: collapse; border: 1px solid grey;">'.$url.' </td></tr>' ;
	return $body; 
}
	

sub _get_filename { 
	my $this = shift;
	my $row = shift; 
	my @cdr = @{$row}; 

	my $cdr_start = $cdr[0]; 
	my $calleridnum = $cdr[2]; 
	
	my ($dir,$fname) = $this->_mixmonitor_filename($cdr_start,$calleridnum);
	my $ffname = $dir.'/'.$fname; 

	return ($fname, $ffname);
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

    my $directory = "/var/spool/asterisk/monitor"; 
#      sprintf( "/var/spool/asterisk/monitor/%s/%s/%s", $year, $mon, $day );

    my $filename = sprintf( "%s/%s/%s/%s%s%s-%s.mp3",
        $year, $mon, $day, $hour, $min, $sec, $callerid_num );

    return ( $directory, $filename );

}	

sub _readfile { 
	my $this = shift; 
	my $fname = shift; 

	open (my $fh, '<', $fname) or return undef; 
	binmode $fh; 
	my $fbody = <$fh>;
	close $fh; 
	return $fbody;
}

			


#===============================================================================

__END__

=head1 NAME

PearlPBX-citycom1.pl

=head1 SYNOPSIS

PearlPBX-citycom1.pl

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

