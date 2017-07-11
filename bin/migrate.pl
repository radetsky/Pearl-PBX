#!/usr/bin/env perl

use 5.8.0;
use strict;
use warnings;

use Config::General;
use DBI;
use Data::Dumper;

my $conf = "/etc/PearlPBX/asterisk-router.conf";

my $config = Config::General->new (
-ConfigFile        => $conf,
-AllowMultiOptions => 'yes',
-UseApacheInclude  => 'yes',
-InterPolateVars   => 'yes',
-ConfigPath        => [ $ENV{PEARL_CONF_DIR}, '/etc/PearlPBX' ],
-IncludeRelative   => 'yes',
-IncludeGlob       => 'yes',
-UTF8              => 'yes',
);

unless ( ref $config ) {
    die "Can't read config!\n";
}

my %cf_hash = $config->getall or ();
$conf = \%cf_hash;

unless ( defined( $conf->{'db'}->{'main'}->{'dsn'} ) ) {
    die "Can't find \"db main->dsn\" in configuration.\n";
}

unless ( defined( $conf->{'db'}->{'main'}->{'login'} ) ) {
    die "Can't find \"db main->login\" in configuraion.\n";
}
unless ( defined( $conf->{'db'}->{'main'}->{'password'} ) ) {
    die "Can't find \"db main->password\" in configuraion.\n";
}

my $dsn    = $conf->{'db'}->{'main'}->{'dsn'};
my $user   = $conf->{'db'}->{'main'}->{'login'};
my $passwd = $conf->{'db'}->{'main'}->{'password'};

my $dbh = DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1, AutoCommit => 0 } );
unless ( defined ( $dbh ))  { die "Cant connect to DBMS!\n"; }

dump_sip_peers();
dump_integration_workplaces();
dump_blacklist();
dump_extensions();
dump_queues();
dump_queue_members();
dump_sip_conf();

dump_directions_list();
dump_directions();
dump_callerid();
dump_permissions();
dump_route(); 
dump_calendar();

exit 1; 

##################################################################################

sub dump_sip_peers {

    my $fields = "id, name,secret,comment,type,context,dtmfmode,fromuser,fromdomain,host,insecure,ipaddr, nat ";
    my $sip_peers_hash_ref = $dbh->selectall_hashref("select $fields from public.sip_peers order by id", 'id');
    foreach my $peer ( keys %{$sip_peers_hash_ref} ) {
        printf("insert into public.sip_peers ( $fields ) values (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s'); \n",
        $sip_peers_hash_ref->{$peer}->{id},
        $sip_peers_hash_ref->{$peer}->{name},
        $sip_peers_hash_ref->{$peer}->{secret},
        $sip_peers_hash_ref->{$peer}->{comment},
        $sip_peers_hash_ref->{$peer}->{type} // 'friend',
        $sip_peers_hash_ref->{$peer}->{context} // 'default',
        $sip_peers_hash_ref->{$peer}->{dtmfmode} // 'rfc2833',
        $sip_peers_hash_ref->{$peer}->{fromuser} // '',
        $sip_peers_hash_ref->{$peer}->{fromdomain} // '',
        $sip_peers_hash_ref->{$peer}->{host} // '',
        $sip_peers_hash_ref->{$peer}->{insecure} // 'invite,port',
        $sip_peers_hash_ref->{$peer}->{ipaddr} // '',
        $sip_peers_hash_ref->{$peer}->{nat} // 'force_rport,comedia',
        );
    }
    dump_seq('public.sip_peers_id_seq');
}

sub dump_integration_workplaces {
    my $fields = 'id, sip_id, ip_addr_pc, ip_addr_tel, teletype, autoprovision, tcp_port, integration_type, mac_addr_tel';
    my $templt = "%d, %d, '%s','%s','%s','%s','%s','%s','%s'";
    my $hash_ref = $dbh->selectall_hashref("select $fields from integration.workplaces order by id",'id'); 
    foreach my $id ( keys %{$hash_ref } ) {
        printf("insert into integration.workplaces ($fields) values ($templt);\n", 
            $hash_ref->{$id}->{id},
            $hash_ref->{$id}->{sip_id},
            $hash_ref->{$id}->{ip_addr_pc},
            $hash_ref->{$id}->{ip_addr_tel},
            $hash_ref->{$id}->{teletype},
            $hash_ref->{$id}->{autoprovision},
            $hash_ref->{$id}->{tcp_port} // 335,
            $hash_ref->{$id}->{integration_type},
            $hash_ref->{$id}->{mac_addr_tel},
        );
    }
    dump_seq('integration.workplaces_id_seq');

}

sub dump_blacklist { 
    my $table  = "public.blacklist";
    my $fields = 'id, number, reason, create_date';
    my $templt = "%d, '%s','%s','%s'";

    my $selected = $dbh->selectall_hashref("select $fields from $table order by id",'id');
    foreach my $id ( keys % { $selected } ) {
        printf("insert into $table ( $fields ) values ($templt);\n", 
            $selected->{$id}->{id},
            $selected->{$id}->{number},
            $selected->{$id}->{reason},
            $selected->{$id}->{create_date},
        );
    }
    dump_seq('public.blacklist_id_seq');
}



sub dump_extensions {
    my $table  = "public.extensions_conf"; 
    my @names = qw/id context exten priority app appdata/; 
    my $fields = join(',', @names);
    my $templt = "%d, '%s', '%s','%s','%s','%s'"; 

    my $selected = $dbh->selectall_hashref("select $fields from $table order by id",'id');
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }
    dump_seq('public.extensions_conf_id_seq');

}

sub dump_queues { 
    my $table = "public.queues";
    my @names = qw/name musiconhold timeout monitor_format retry wrapuptime maxlen servicelevel strategy joinempty leavewhenempty memberdelay weight timeoutrestart ringinuse setinterfacevar autofill autopause/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/'%s' '%s' %d '%s' %d %d %d %d '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by name",'name'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }
}

sub dump_queue_members {
    my $table = "public.queue_members"; 
    my @names = qw/uniqueid membername queue_name interface penalty paused/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d '%s' '%s' '%s' '%s' '%s'/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by uniqueid",'uniqueid'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('public.queue_members_uniqueid_seq');
}

sub dump_sip_conf {
    my $table = "public.sip_conf";
    my @names = qw/id cat_metric var_metric commented filename category var_name var_val/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d %d %d %d '%s' '%s' '%s' '%s'/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by id",'id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('public.sip_conf_id_seq');

}

sub dump_directions_list {

    my $table = "routing.directions_list"; 
    my @names = qw/dlist_id dlist_name/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d '%s'/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by dlist_id",'dlist_id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('routing."directions_list_DLIST_ID_seq"');

}

sub dump_directions { 

    my $table = "routing.directions";
    my @names = qw/dr_id dr_list_item dr_prefix dr_prio/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d %d '%s' %d/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by dr_id",'dr_id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('routing.directions_dr_id_seq');
}

sub dump_callerid { 

    my $table = "routing.callerid";
    my @names = qw/id direction_id sip_id set_callerid/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d %d '%s' '%s'/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by id",'id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('routing.callerid_id_seq');

}

sub dump_permissions { 

    my $table = "routing.permissions";
    my @names = qw/id direction_id peer_id/;
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d %d %d/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by id",'id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('routing.permissions_id_seq');

}

sub dump_route {
    my $table = "routing.route";
    my @names = qw/route_id route_direction_id route_step route_type route_dest_id route_sip_id/; 
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d %d %d '%s' %d %s/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by route_id",'route_id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('routing.route_route_id_seq');

}

sub dump_calendar { 
    my $table = "cal.timesheet";
    my @names = qw/id weekday mon_day mon year time_start time_stop group_name is_work prio/; 
    my $fields = join(',', @names); 
    my $templt = join(',', qw/%d %s %s %s '%s' '%s' '%s' '%s' '%s' '%s'/);

    my $selected = $dbh->selectall_hashref("select $fields from $table order by id",'id'); 
    foreach my $id ( keys %{ $selected }) {
        my @fmt_data = format_data (\@names, $selected->{$id} );
        printf("insert into $table ( $fields ) values ($templt);\n", @fmt_data )
    }

    dump_seq('cal.timesheet_id_seq');

}

sub format_data {
    my $names = shift; 
    my $data  = shift; 

    my @result; 

    foreach my $name ( @{$names} ) {
        push @result, $data->{$name} // 'NULL'; 
    }

    return @result; 
}

sub dump_seq {
    my $seq_name = shift; 
    unless (defined ( $seq_name ) ) { 
        return undef; 
    }
    my $seq = $dbh->selectrow_hashref("select last_value from $seq_name"); 
    printf("alter sequence $seq_name restart with %d;\n", $seq->{last_value}+1);
}
1;


