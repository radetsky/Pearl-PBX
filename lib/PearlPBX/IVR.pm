#===============================================================================
#
#         FILE:  IVR.pm
#
#  DESCRIPTION:  Base class for all IVR applications of PearlPBX 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  07.03.2013 08:21:27 EET
#===============================================================================
=head1 NAME

PearlPBX::IVR

=head1 SYNOPSIS

	use base PearlPBX::IVR;

=head1 DESCRIPTION

=cut

package PearlPBX::IVR;

use 5.8.0;
use strict;
use warnings;

use base 'NetSDS::App';
use Data::Dumper; 
use Asterisk::AGI;

use version; our $VERSION = "1.00";
our @EXPORT_OK = qw();

sub new {

        my ( $class, %params ) = @_;

        my $this = $class->SUPER::new(
                name          => undef,                # application name
                pid           => $$,                   # proccess PID
                debug         => undef,                # debug mode flag
                daemon        => undef,                # daemonize if 1
                verbose       => undef,                # be more verbose if 1
                use_pidfile   => undef,                # check PID file if 1
                pid_dir       => '/var/run/NetSDS',    # PID files catalog (default is /var/run/NetSDS)
                conf_file     => '/etc/PearlPBX/asterisk-router.conf',                # configuration file name
                conf          => undef,                # configuration data
                logger        => undef,                # logger object
                has_conf      => 1,                    # is configuration file necessary
                auto_features => 0,                    # are automatic features allowed or not
                infinite      => 1,                    # is infinite loop
                edr_file      => undef,                # path to EDR file
                %params,
        );

        return $this;

} ## end sub new

sub run {

        my $class = shift(@_);

        # Create application instance
        if ( my $app = $class->new(@_) ) {

                # Framework initialization
                $app->initialize(@_);

                # Application workflow
                $app->main_loop();

                # Framework finalization
                $app->finalize();

        } else {

                die "Can't start application";
                return undef;

        }

} ## end sub run

sub initialize {
        my ( $this, %params ) = @_;

        $this->speak("Initializing application.");
        # Determine application name from process name
        if ( !$this->{name} ) {
                $this->_determine_name();
        }

        # Get CLI parameters
        $this->_get_cli_param();

        # Create syslog handler
        if ( !$this->logger ) {
                $this->logger( NetSDS::Logger->new( name => $this->{name} ) );
                $this->log( "info", "Logger started" );
        }

        # Initialize configuration
        if ( $this->{has_conf} ) {
                # Automatically determine configuration file name
                if ( $params{'conf_file'} ) { 
			$this->{conf_file} = $params{'conf_file'}; 
		} 
                if ( !$this->{conf_file} ) {
                        $this->{conf_file} = $this->config_file( $this->{name} . ".conf" );
                }
                $this->log( "info", "Conffile: " . $this->{conf_file} );

                # Get configuration file
                if ( my $conf = NetSDS::Conf->getconf( $this->{conf_file} ) ) {
                        $this->conf($conf);
                        $this->log( "info", "Configuration file read OK: " . $this->{conf_file} );
                } else {
                        $this->log( "error", "Can't read configuration file: " . $this->{conf_file} );
                }

        } ## end if ( $this->{has_conf})
}


sub start { 
	my ($this, %params) = @_; 

	# Read the config done by base class; see this->conf 

  # Make the accessors 
	$this->mk_accessors('dbh');
	$this->mk_accessors('agi');

  # AGI startup
	$this->agi( new Asterisk::AGI );
	$this->agi->ReadParse();
	$this->agi->_debug(10);

	# Connect to the database 
	$this->_db_connect();

}

sub process { 
	my $this = shift; 
	
	$this->agi->verbose("Hello, Asterisk!",3);   

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

1; 

__END__

=back

=head1 EXAMPLES


=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut


