#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-tftpprovisor.pl
#
#        USAGE:  ./PearlPBX-tftpprovisor.pl 
#
#  DESCRIPTION:  Программа, которая генерирует конфигурационные файлы для телефонов из шаблонов. 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  06.02.2013 19:13:00 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

PearlPBXTFTPProvisor->run(
	daemon      => undef,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/PearlPBX/asterisk-router.conf",
    infinite    => undef
);

1; 

package PearlPBXTFTPProvisor; 

use 5.8.0;
use strict;
use warnings;

use base qw(NetSDS::App);
use Data::Dumper;
use DBI;
use Getopt::Long qw(:config auto_version auto_help pass_through);
use Template; 

sub start { 
	my $this = shift; 

	
    my $fromdb  = undef; GetOptions ( 'fromdb' => \$fromdb );   $this->{'fromdb'} = $fromdb; 
    my $macaddr = undef; GetOptions ( 'macaddr=s' => \$macaddr ); $this->{'macaddr'} = $macaddr; 
    my $exten   = undef; GetOptions ( 'exten=s' => \$exten );     $this->{'exten'} = $exten; 
    my $secret  = undef; GetOptions ( 'secret=s' => \$secret );   $this->{'secret'} = $secret; 
    my $sipserv = undef; GetOptions ( 'sipserv=s' => \$sipserv ); $this->{'sipserv'} = $sipserv; 
    my $model   = undef; GetOptions ( 'model=s' => \$model );     $this->{'model'} = $model; 

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

    $this->{'sth'} = $this->dbh->prepare (
" select a.name,a.secret,a.callerid,b.teletype,b.mac_addr_tel 
	from public.sip_peers a, integration.workplaces b where a.id=b.sip_id"  );


    return 1;

}


sub process { 
	my $this = shift; 

	if ( $this->{'fromdb'} ) { 
		# Non interactive mode 
	    print "Reading from database.\n";
    	$this->read_fromdb();
        return 1; 
	} 
    warn Dumper ($this);

    if ( $this->{'macaddr'} ) {
        if ( $this->{'exten'} ) { 
            if ( $this->{'secret'} ) { 
                if ( $this->{'model'}) { 
                    my $struct = { 
                        name => $this->{'exten'},
                        secret => $this->{'secret'},
                        mac_addr_tel => $this->{'macaddr'},
                        teletype => $this->{'model'}
                    };
                    if ($this->{'sipserv'} ) { 
                        $struct->{'sipserv'} = $this->{'sipserv'}; 
                    } else { 
                        $struct->{'sipserv'} = $this->{conf}->{'provision'}->{'sipserv'}; 
                    }
                    $this->save_config($struct);
                    return 1; 
                }
            }
        }
    }

	$this->usage();

}

sub read_fromdb { 
	my $this = shift; 
	eval { 
		$this->{'sth'}->execute(); 
	};

	if ( $@ ) { 
		$this->_exit($this->{dbh}->errstr); 
	}

	my $hr = $this->{'sth'}->fetchall_hashref('name'); 
	#warn Dumper ($hr); 
	
	foreach my $name ( keys %{$hr} )  { 
        #warn Dumper ($hr->{$name}); 
		$this->save_config($hr->{$name}); 
	}

	return keys %{$hr}; # return scalar - count of the names; 
}

sub save_config { 
	my $this = shift; 
	my $struct = shift; # name,secret,mac_addr_tel. 
    my $tftpdir = "/var/lib/tftpboot";

    my $teletype = $struct->{'teletype'}; 
    if ($teletype =~ /softphone/) { 
        # Простые софтфоны не провижионим.
        return undef; 
    }
    unless ( $struct->{'mac_addr_tel'} ) { 
        # Не задан мак адрес 
        return undef; 
    }

    my $templates_dir = '/usr/share/pearlpbx/provision/'; 
    my $tpl_file = $teletype.".cfg";

    my $sipserv = $this->{conf}->{'provision'}->{'sipserv'};
    unless ( defined ( $sipserv ) ) { 
        $sipserv = '127.0.0.1'; 
    }

    unless ( -f $templates_dir.$tpl_file ) {
        if ($this->{verbose}) { 
            warn "File [$tpl_file] does not exists\n";
        }
        $this->log("info","File [$tpl_file] does not exists");
        return undef; 
    }

    my $template = Template->new( { 
            INCLUDE_PATH => '/usr/share/pearlpbx/provision',
            OUTPUT_PATH => '/var/lib/tftpboot',
            INTERPOLATE  => 1, 
            } ) || die "$Template::ERROR\n"; 
    
    my $template_vars = { 
        name => $struct->{'name'},
        macaddr => $struct->{'mac_addr_tel'},
        secret => $struct->{'secret'},
        sipserv => $sipserv, 
    };

    my $output = $struct->{'mac_addr_tel'}.".txt"; # Grandstream 
    if ($teletype =~ /^SPA/) { 
        $output = $teletype.'/'.$struct->{'mac_addr_tel'}.".xml"; 
    }

    unless ( $template->process($tpl_file, $template_vars, $output )) {
        if ($this->{verbose}) { 
            warn "Can't process $tpl_file " . $template->error() . "\n";
        }
        $this->log("error","Can't process $tpl_file " . $template->error()); 
        return undef; 
    } 
    if ($teletype =~ /^GrandStreamGXP/i ) { 
        system "grandstream-config.pl ".$struct->{'mac_addr_tel'}." $tftpdir".'/'.$output." $tftpdir/cfg".$struct->{'mac_addr_tel'};
        unlink $tftpdir.'/'.$output; 
    }

    return 1; 

}

sub _exit { 
	my ($this,$str) = @_; 

	die $str . "\n"; 
}

sub usage { 
	my $this = shift; 

	print "Usage: $0 [ --fromdb ][ --macaddr ][ --sipserv ][ --exten][ --secret][ --model]\n";
    return; 
}




1;
#===============================================================================

__END__

=head1 NAME

PearlPBX-tftpprovisor.pl

=head1 SYNOPSIS

PearlPBX-tftpprovisor.pl

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

