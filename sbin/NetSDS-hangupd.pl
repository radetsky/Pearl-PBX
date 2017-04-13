#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  NetSDS-hangupd.pl
#
#        USAGE:  ./NetSDS-hangupd.pl
#
#  DESCRIPTION:  Hangup daemon. Listens AMI for hangup events and clears the integration.ulines table.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  12/19/11 11:24:06 EET
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

NetSDSHangupD->run(
    daemon      => 1,
    verbose     => 1,
    use_pidfile => 1,
    has_conf    => 1,
    conf_file   => "/etc/NetSDS/asterisk-router.conf",
    infinite    => undef
);

1;

package NetSDSHangupD;

use 5.8.0;
use strict;
use warnings;
use DBI;

use base qw(PearlPBX::App); # Already connected to Database, Manager and EventListener
use Data::Dumper;
use LWP::UserAgent;
use PearlPBX::Logger; 

our @expire_list = ();

sub start {
    my $this = shift;
    $this->SUPER::start();
    $this->_clear_ulines();
    $this->{'count'} = 0;
}

sub _clear_ulines {
    my $this = shift;

    Info("Start clear ulines procedure.");
    Info("Getting status from AMI.");
    # get status
    my @liststatus = $this->_get_status;
    Info("Got status. Getting busy ulines.");
    my $busyulines = $this->_get_busy_ulines;

    # compare channels with ulines
    my $id      = undef;
    my $channel = undef;
    my $found   = undef;

    foreach my $i ( @{$busyulines} ) {
        $id      = ${$i}[0];
        $channel = ${$i}[1];
        $found   = undef;
        foreach my $status (@liststatus) {
            if ( $status->{'Channel'} eq $channel ) {
                $found = 1;
                last;
            }
        }
        unless ( defined($found) ) {
            $this->_free_uline($channel);
        }
    }

    # clear offline channels
    Info("Ulines cleared. Going to process().");
}

sub _get_status {
    my $this    = shift;
    my $manager = $this->mgr; 

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

    # reading from socket while did not receive Event: StatusComplete

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

sub _get_busy_ulines {
    my $this = shift;

    my $sth = $this->dbh->prepare(
        "select id,channel_name from integration.ulines where status='busy' order by id asc"
    );
    eval { my $rv = $sth->execute; };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $busylines = $sth->fetchall_arrayref;
    return $busylines;
}

sub _get_uline_by_channel {
    my $this    = shift;
    my $channel = shift;

    my $sth = $this->dbh->prepare(
        "select id from integration.ulines where channel_name=? and status='busy' order by id asc limit 1"
    );
    eval { my $rv = $sth->execute($channel); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my $result = $sth->fetchrow_hashref;

    unless ( defined( $result ) ) {
        return undef;
    }
    return $result->{'id'};
}

sub _integration_free {
    my ( $this, $uline, $itype, $userfield ) = @_;

    if ( $itype =~ /YourTaxi/ ) {
        my $ua = LWP::UserAgent->new;
        $ua->timeout(1);
        $ua->env_proxy;

        my $your_taxi_server_ip = $this->{conf}->{ytaxi_api_host_port} // '192.168.0.210:8000';
        my $url =
            sprintf( "http://%s/YTaxi/ru/ManagePBX/HangUp?provider=%s&line=%s",
            $your_taxi_server_ip, $userfield, $uline );

        Info($url);
        my $response = $ua->get($url);

        if ( $response->is_success ) {
            Info($response->decoded_content);
        }
        else {
            Err( $response->status_line );
        }
    }
}

sub _free_uline {
    my $this    = shift;
    my $channel = shift;

    $this->_begin;
    my $sth = $this->dbh->prepare(
        "select id,integration_type,userfield from integration.ulines 
            where channel_name=? and status='busy' order by id asc limit 1 for update"
    );

    eval { my $rv = $sth->execute($channel); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }

    my $result = $sth->fetchrow_hashref;
    unless ( defined ( $result ) ) {
        Infof( "Hangup %s, but integration.ulines does not has it.", $channel );
        $this->dbh->rollback;
        return undef;
    }

    my $id        = $result->{'id'};
    my $itype     = $result->{'integration_type'};
    my $userfield = $result->{'userfield'};

    Infof ( "free_uline: id=%s,itype=%s,userfield=%s", $id, $itype, $userfield );
    $this->_integration_free( $id, $itype, $userfield );

    $sth = $this->dbh->prepare(
        "update integration.ulines set status='free' where id=?");
    eval { my $rv = $sth->execute($id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    $this->dbh->commit;

    Infof("uline %s with %s cleared", $id, $channel );
    $this->_recording_set_final($id);

    return 1;
}

sub _recording_set_final {
    my $this     = shift;
    my $uline_id = shift;

    $this->_begin;

    my $sth = $this->dbh->prepare(
        "select id from integration.recordings where uline_id=? and next_record is NULL 
        order by id"
    );

    eval { my $rv = $sth->execute($uline_id); };
    if ($@) {
        $this->_exit( $this->dbh->errstr );
    }
    my @ids = ();

    while ( my $result = $sth->fetchrow_hashref ) {
        push @ids, $result->{'id'};
    }

    $sth = $this->dbh->prepare(
        "update integration.recordings set next_record=0 where id=?");

    foreach my $rec_id (@ids) {
        eval { my $rv = $sth->execute($rec_id); };
        if ($@) {
            $this->_exit( $this->dbh->errstr );
        }
        Infof("Record # %s for line # %s set as final.", $rec_id, $uline_id );
    }

    $this->dbh->commit;
    return 1;

}

sub _add_2_expire {
    my $this        = shift;
    my $channel     = shift;
    my $uline       = shift;
    my $expire_time = shift;

    Info ("added to expire list $uline $channel $expire_time" );
    push @expire_list,
        { channel => $channel, uline => $uline, expire_time => $expire_time };

}

sub _expire_ulines {
    my $this = shift;
    my $t    = undef;
    my $item = undef;

    while (1) {
        $t    = time();
        $item = shift @expire_list;
        unless ($item) {
            last;
        }

        if ( $item->{'expire_time'} <= $t ) {
            Infof("Time: %s to free uline %s with %s ", $t, $item->{'uline'}, $item->{'channel'} );
            $this->_free_uline( $item->{'channel'} );
        }
        else {
            unshift @expire_list, $item;
            last;
        }
    }

    return 1;

}

sub process {
    my $this = shift;

    my $event   = undef;
    my $channel = undef;
    my $uline   = undef;

    while (1) {
        $event = $this->el->_getEvent();
	unless ( defined ( $event ) ) { 
	    $this->_exit("EOF from manager. Exiting to restart by system methods (systemctl, monit)");
	}
        if ($event == 0) {
            $this->{'count'} = $this->{'count'} + 1;
            if ( $this->{'count'} >= 300 ) {
                $this->_clear_ulines();
                $this->{'count'} = 0;
            }
            sleep(1);
            $this->_expire_ulines();
            next;
        }

        unless ( defined( $event->{'Event'} ) ) {
            Debugf("STRANGE EVENT: %s ", $event ); 
            next;
        }

        if ( $event->{'Event'} =~ /Hangup/i ) {
            $channel = $event->{'Channel'};
            Info("HangUp for $channel" );
            $uline = $this->_get_uline_by_channel($channel);
            unless ( defined($uline) ) {
                next;
            }
            $this->_add_2_expire( $channel, $uline, time() + 3 );
        }
        $this->_expire_ulines();
    }
}

1;

#===============================================================================

__END__

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

