package PearlPBX::Dialer; 

use warnings; 
use strict; 

use Data::Dumper;
use Proc::Daemon; 

use PearlPBX::NotifyHTTP qw(notify_http);
use PearlPBX::Logger;
use PearlPBX::DB;

use NetSDS::Asterisk::Manager;
use NetSDS::Asterisk::EventListener; 

use constant MAX_TRIES    => 5;
use constant CALL_TIMEOUT => 60*1000;
use constant PEARLPBX_TIMEOUT => 120;
use constant BUSY_TIMEOUT => 30;
use constant REASON => {
        '0' => 'CONGESTION',
        '1' => 'HANGUP',
        '2' => 'LRINGING',
        '3' => 'RINGING',
        '4' => 'ANSWERED',
        '5' => 'BUSY',
        '6' => 'OFFHOOK1',
        '7' => 'OFFHOOK2',
        '8' => 'NO ANSWER',
    };

use constant PARAMS => qw (src dst taskName _notifyURL _fork); 

sub new {
	my ($class, $params) = @_; 
	my $this; 

	# Validate reqired parameters 
	foreach my $key ( PARAMS ) {
		if ( $key =~ /^_/ ) {
			$this->{$key} = $params->{$key};
			next; # Optional parameter 
		}
		if ( ! defined ( $params->{$key} ) ) {
			die "Required parameter $key not found!\n";
		}
		$this->{$key} = $params->{$key};
	} 
	# Fork
	if ( $this->{_fork} ) {
		Proc::Daemon::Init; 
	}

	$this->{db} = PearlPBX::DB->new(); 
	$this->{dbh} = $this->{db}->{dbh}; 
	$this->{mgr} = PearlPBX::Manager->new();
	$this->{evt} = PearlPBX::EventListener->new(); 

	return bless $this, $class; 
}
1;
