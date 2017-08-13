package PearlPBX::Permissions;

use warnings;
use strict;

use PearlPBX::Config qw/conf/;
use PearlPBX::DB qw/pearlpbx_db/;
use PearlPBX::HttpUtils qw/http_response/;

use JSON::XS;
use NetSDS::Util::String;
use Data::Dumper;

use Exporter;
use parent qw(Exporter);

our @EXPORT = qw (
    permissions_show
    permissions_update
);

=item B<permissions_show>

    Return table of permissions to page Permissions

=cut

sub permissions_update {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $permissions = $params->{'matrix'};
    unless ( defined ( $permissions ) ) {
        return http_response($env,400,"No permissions given");
    }

    my (@matrix) = split (',',$permissions);
    my $mat = @matrix;
    my $count = 0;

    foreach my $element ( @matrix ) {
        $element =~ /^X(\d+).Y(\d+)=(\d)$/;
        my $sip_peer = $1;
        my $direction_id = $2;
        my $val = $3;

        if ( ( $sip_peer > 0 ) and ( $direction_id > 0 ) ) {
            if ( $val > 0 ) {
                my $sql = "select * from routing.permissions where peer_id=? and direction_id=?";
                my $sth = pearlpbx_db()->prepare($sql);
                eval { $sth->execute ($sip_peer,$direction_id); };
                if ($@) {
                    return http_response($env,400,pearlpbx_db()->errstr);
                }
                my $row = $sth->fetchrow_hashref;
                unless ( $row->{'id'} ) {
                    pearlpbx_db()->do ("insert into routing.permissions (peer_id,direction_id) values ($sip_peer,$direction_id)");
                }
            }
            if ( $val == 0 ){
                pearlpbx_db()->do ("delete from routing.permissions where peer_id=".$sip_peer." and direction_id=".$direction_id);
            }
            $count++;
       }
    }
    return http_response($env,200,"OK");
}

sub permissions_show {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $format = $params->{'format'} // 'JSON';

    my $sql = "select direction_id, peer_id from routing.permissions order by id";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute; };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    my @rows;
    while (my $row = $sth->fetchrow_hashref) {
        push @rows,$row;
    }

    if ( $format eq 'html') {
        return permissions_show_html($env,@rows);
    }

    return http_response($env,200, encode_json (\@rows));
}

sub permissions_show_html {
    my $env = shift;
    my @permissions = @_;

    my $out = "<table class=\"table table-bordered table-hover table-condensed\" id=\"pearlpbx_permissions_table\">";
    $out .= "<thead><tr>";
    my $directions = _get_directions_list();
    unless ( defined ( $directions ) ) {
        return http_response($env,400,"No one direction not found");
    }
    $out .= "<th colspan=2>".str_encode("Select all")."</th>";
    my $out2 .= "<tr><th colspan=2><input type=\"checkbox\" id=\"XYall\" onChange=\"pearlpbx_permissions_selectall()\"></th>";
    my $Xcount = @{$directions}; # Количество направлений
    foreach my $dir ( @{$directions} ) {
        $out .= "<th>".$dir->{'dlist_name'}."</th>";
        my $checkboxY = "<input type=\"checkbox\" id=\"Y".$dir->{'dlist_id'}."\" onChange=\"pearlpbx_permissions_set_y('Y".$dir->{'dlist_id'}."')\">";
        $out2 .= "<th style=\"background: grey;\">".$checkboxY."</th>";
    }
    $out2 .= "</tr>";
    $out .= "</tr>".$out2."</thead>";

    my $sip_peers = _get_sip_peers();
    unless ( defined ( $sip_peers ) ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    my $Ycount = @{$sip_peers};
    foreach my $sip_peer ( @{$sip_peers} ) {
        $out .= "<tr><th>".$sip_peer->{'name'}."</th>";
        $out .= "<th style=\"background: grey;\"><input type=\"checkbox\" id=\"X".$sip_peer->{'id'}."\" onChange=\"pearlpbx_permissions_set_x('X".$sip_peer->{'id'}."')\"></th>";
        for (my $x = 0; $x < $Xcount; $x++) {
            $out .= "<td><input type=\"checkbox\" id=\"X".$sip_peer->{'id'}."_Y".${$directions}[$x]->{'dlist_id'}."\"></td>";
        }
    }

    $out .= "</table>";
    return http_response($env,200,$out);

}

sub _get_directions_list {
    my $sql = "select dlist_id,dlist_name from routing.directions_list order by dlist_name";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute(); };
    if ( $@ ) {
        return undef;
    }
    my @d;
    while ( my $row = $sth->fetchrow_hashref ) {
        $row->{'dlist_name'} = str_encode($row->{'dlist_name'});
        push @d,$row;
    }
    return \@d;
}

sub _get_sip_peers {
    my $sql = "select id, name, comment from public.sip_peers order by name";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute(); };
    if ($@) {
        return undef;
    }
    my @rows;
    while (my $row = $sth->fetchrow_hashref) {
        $row->{'comment'} = str_encode ( $row->{'comment'});
        push @rows,$row;
    }
    return \@rows;
}

1;


