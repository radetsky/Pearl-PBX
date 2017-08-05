package PearlPBX::Trunkgroups;

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
    trunkgroups_id
    trunkgroups_list
    trunkgroups_add
    trunkgroups_update
    trunkgroups_remove
    trunkgroups_channels
    trunkgroups_addmember
    trunkgroups_delmember
);
=item B<trunkgroups_id>

    Return ID of trunkgroup by name

=cut

sub trunkgroups_id {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $name = $params->{'name'};

    if (!defined ($name) || ($name eq '') ) {
        return http_response($env,400,"-1");
    }
    my $sql = "select tgrp_id from routing.trunkgroups where tgrp_name=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($name); };
    if ( $@ ) {
        return http_response($env, 400, pearlpxb_db()->errstr);
    }
    my $row = $sth->fetchrow_hashref;
    return http_response($env,200,$row->{'tgrp_id'});
}


=item B<trunkgroups_list>

    Return list of Trunkgroups as HTML table or <OPTION> list </OPTION>

=cut

sub trunkgroups_list {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $format = $params->{'format'} // 'table';

    my $sql = "select tgrp_id, tgrp_name from routing.trunkgroups order by tgrp_name";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute(); };
    if ( $@ ) { return http_response($env, 400, pearlpbx_db()->errstr); };

    my @list;
    while ( my $row = $sth->fetchrow_hashref ) {
       push @list, $row; # sorted array by database
    }

    if ($format eq 'table') {
        return trunkgroups_list_html($env, @list);
    }

    # List as OPTION
    my $out = '';
    foreach my $row ( @list ) {
         $out .= '<option value="'.$row->{'tgrp_id'}.'">'.$row->{'tgrp_name'}.'</option>';
    }
    return http_response($env, 200, $out);
}

=item B<trunkgroups_list_html>

    Return HTML Table view of PBX trunkgroups

=cut

sub trunkgroups_list_html {
    my $env = shift;
    my @list = @_;

    my $out = '<table class="table table-bordered table-hover">
    <tr><th>Trunk group Name</th><th>Channels</th></tr>';

    foreach my $row ( @list ) {
        my @members = trunkgroups_members_list($row->{'tgrp_id'});
        my $members_names = join (',', map { $_->{'name'} } @members );

        $out .= '<tr><td><a href="#pearlpbx_trunkgroup_edit" data-toggle="modal"
        onClick="pearlpbx_trunkgroup_load_by_id(\''.$row->{'tgrp_id'}.'\',
        \''.$row->{'tgrp_name'}.'\')">'.str_encode($row->{'tgrp_name'}).'</a>
        </td><td>'.str_encode($members_names).'</td></tr>';
    }
    $out .= '</table>';
    return http_response($env,200,$out);
}

=item B<trunkgroups_channels>

    Return JSON with trunkgroup channels

=cut

sub trunkgroups_channels {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $id = $params->{'tgrp_id'};

    unless ( defined ( $id ) ) {
        return http_response($env, 400, '');
    }
    my @members = trunkgroups_members_list($id);

    return http_response($env,200, encode_json(\@members));
}

=item B<trunkgroups_members_list>

    Return ARRAY of trunkgroups items.
    Each item is hashref with 'name' property.

=cut

sub trunkgroups_members_list {
    my $tgrp_id = shift;

    my $sql = "select a.tgrp_item_id, a.tgrp_item_peer_id, b.name
        from routing.trunkgroup_items a , public.sip_peers b
            where a.tgrp_item_group_id = ? and a.tgrp_item_peer_id = b.id
                order by b.name";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($tgrp_id); };
    if ( $@ ) {
        return '';
    }
    my @rows;
    while ( my $row = $sth->fetchrow_hashref ) {
        push @rows, $row;
    }

    return @rows;
}

=item B<trunkgroups_add>

    Add the new empty trunkgroup

=cut

sub trunkgroups_add {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $name = $params->{'name'};

    if (!defined ($name) || ($name eq '') ) {
        return http_response($env,400,"Name can not be empty!");
    }

    my $sql = "insert into routing.trunkgroups (tgrp_name) values (?)";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($name); };
    if ( $@ ) { return http_response($env,400,pearlpbx_db()->errstr); }
    return http_response($env,200,"OK");
}

=item B<trunkgroups_addmember>

    Add the SIP/${member_id} to trunkgroup ${tgrp_id}
    Returns OK, ALREADY or error

=cut

sub trunkgroups_addmember {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $member_id = $params->{'member'};
    my $tgrp_id   = $params->{'tgrp_id'};

    if ( (!defined ($member_id) ) || ( !defined ( $tgrp_id ) ) ) {
       return http_response($env,400,"Parameters member,tgrp_id is required");
    }

    #check for existing member in trunkgroup
    my $sql = "select tgrp_item_id from routing.trunkgroup_items where tgrp_item_peer_id=? and tgrp_item_group_id=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($member_id,$tgrp_id); };
    if ($@) {
      return http_response($env,400,pearlpbx_db()->errstr);
    }
    my $row = $sth->fetchrow_hashref;
    if ($row->{'tgrp_item_id'}) {
       return http_response($env,200,"ALREADY");
    }
    $sql = "insert into routing.trunkgroup_items (tgrp_item_peer_id,tgrp_item_group_id) values (?,?);";
    $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ($member_id, $tgrp_id); };
    if ( $@ ) {
       return http_response($env,400,pearlpbx_db()->errstr);
    }
    return http_response($env,200,"OK");
}

=item B<trunkgroups_delmember>

    Remove member from trunkgroup

=cut

sub trunkgroups_delmember {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $tgrp_item_id   = $params->{'tgrp_item_id'};

    if (!defined ($tgrp_item_id) ) {
       return http_response($env,400,"Parameter tgrp_item_id is required");
    }

    my $sql = "delete from routing.trunkgroup_items where tgrp_item_id=?";
    my $sth = pearlpbx_db()->prepare($sql);

    eval { $sth->execute($tgrp_item_id); };
    if ($@) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    return http_response($env,200,"OK");
}

sub trunkgroups_update {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $name = $params->{'name'};
    my $tgrp_id = $params->{'tgrp_id'};

    if (!defined ($name) || ($name eq '') ) {
        return http_response($env,400,"Name can not be empty!");
    }
    if (!defined ($tgrp_id) ) {
        return http_response($env,400,"tgrp_id is not defined");
    }
    my $sql = "update routing.trunkgroups set tgrp_name=? where tgrp_id=?";
    my $sth = pearlpbx_db()->prepare ($sql);
    eval { $sth->execute($name,$tgrp_id);};
    if ($@) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    return http_response($env,200,"OK");
}

sub trunkgroups_remove {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $tgrp_id = $params->{'tgrp_id'};

    if (!defined ($tgrp_id) ) {
        return http_response($env,400,"tgrp_id is not defined");
    }
    my $sql = "delete from routing.trunkgroups where tgrp_id=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($tgrp_id);};
    if ($@) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    return http_response($env,200,"OK");
}

1;


