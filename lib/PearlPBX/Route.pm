#===============================================================================
#
#         FILE:  Route.pm
#
#  DESCRIPTION:  PearlPBX Route management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  23.06.2012
#      MODIFIED: 20.07.2017
#      REVISION: 2
#===============================================================================
=head1 NAME

PearlPBX::Route

=head1 SYNOPSIS

	use PearlPBX::Route;

=cut

package PearlPBX::Route;

use strict;
use warnings;

use DBI;
use Config::General;
use JSON::XS;
use NetSDS::Util::String;

use PearlPBX::Config qw/conf/;
use PearlPBX::DB qw/pearlpbx_db/;
use PearlPBX::HttpUtils qw/http_response/;
use Data::Dumper;

use Exporter;
use parent qw(Exporter);

our @EXPORT = qw (
    route_manager_credentials
    route_get_ulines
    route_list
    route_get_direction
    route_get_routing
    route_addprefix
    route_removeprefix
    route_addrouting
    route_removerouting
    route_savedirection
    route_removedirection
    route_adddirection
);


sub route_manager_credentials {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $res = $req->new_response(200);

    my $conf = conf();
    $res->body(encode_json($conf->{webuser}->{manager}));
    $res->finalize($env);
}


sub route_get_ulines {
  my $env = shift;
  my $req = Plack::Request->new($env);

  my $sql = "select * from integration.ulines where status='busy' order by id";
  my $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute; };
  if ( $@ ) {
      my $res = $req->new_response(400);
      $res->body(pearlpbx_db()->errstr);
      $res->finalize($env);
  }

  my @rows;

  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }

  my $res = $req->new_response(200);
  $res->body(encode_json(\@rows));
  $res->finalize($env);
}

=item B<route_list>

 Returns HTML view of directions list depends on format (HTML table, options )

=cut

sub route_list {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;

    my $format = $params->{'format'} // 'table';

	my $sql = "select dlist_id,dlist_name from routing.directions_list order by dlist_name";

	my $sth = pearlpbx_db()->prepare($sql);
	eval { $sth->execute(); };
	if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
	}

    my @list;
    while ( my $row = $sth->fetchrow_hashref ) {
       push @list, $row; # sorted array by database
    }

    if ($format eq 'table') {
        return route_list_table($env, @list);
    }
    # List as OPTION
    my $out = '';
    foreach my $row ( @list ) {
        my $dname = str_encode ($row->{'dlist_name'});
        $out .= '<option value="'.$row->{'dlist_id'}.'">'.$dname.'</option>';
    }
    return http_response($env, 200, $out);
}

sub route_list_table {
    my $env = shift;
    my @list = @_;

    my $out = '<table class="table table-bordered table-hover">
                <tr><th>Route Name</th><th>Prefixes</th></tr>';

    foreach my $row (@list) {
      my @prefixes = route_get_prefixes($row->{'dlist_id'});
      my $prefixesString = join (',', map { $_->{'dr_prefix'} } @prefixes );

      my $dname = str_encode ($row->{'dlist_name'});
	  $out .= '<tr><td><a href="#pearlpbx_direction_edit" data-toggle="modal"
         onClick="pearlpbx_direction_load_by_id(\''.$row->{'dlist_id'}.'\',
          \''.$dname.'\')">'.$dname.'</a></td><td>'.$prefixesString.'</td></tr>';
	}
    $out .= "</table>";
	return http_response($env, 200, $out);
}

sub route_get_prefixes {
  my $dlist_id = shift;

  my $sql = "select dr_id, dr_prefix, dr_prio from routing.directions where dr_list_item=? order by dr_id";
  my $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute($dlist_id); };
  if ( $@ ) {
      return undef;
  }
  my @rows;
  while ( my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  return @rows;
}

=item B<route_get_direction>

    Returns route parameters in JSON

=cut

sub route_get_direction {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;
  my $route_id = $params->{'id'};

  unless ( defined ( $route_id ) ) {
    return http_response($env, 400, "route ID not found");
  }

  my @rows = route_get_prefixes($route_id);
  return http_response($env,200, encode_json(\@rows));
}

=item B<route_get_routing>

    Return routing information for route as JSON

=cut

sub route_get_routing {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $route_id = $params->{'id'};

    unless ( defined ( $route_id ) ) {
        return http_response($env,400,"route ID not found");
    }

    my $sql = "select route_id, route_step, route_type, destname, sipname from \
      routing.get_route_list_gui() where route_direction_id=? order by route_step,sipname";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($route_id); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    my @rows;
    while ( my $row = $sth->fetchrow_hashref) {
       push @rows, $row;
    }
    return http_response($env,200,encode_json(\@rows));
}

=item B<route_addprefix>

    Checks and adds prefix to route

=cut

sub route_addprefix {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;
  my $dlist_id = $params->{'route_id'};
  unless ( defined ( $dlist_id) ) {
      return http_response($env,400,'route_id is not defined');
  }
  my $prefix = $params->{'prefix'};
  unless ( defined ( $prefix ) ) {
      return http_response($env,400,'prefix is not defined');
  }
  my $prio = $params->{'priority'};
  unless ( defined ( $prio ) ) {
      return http_response($env,400,'priority is not defined ');
  }

  my $sql = "select dr_id,dr_list_item from routing.directions where dr_prefix=?";
  my $sth = pearlpbx_db()->prepare ($sql);
  eval { $sth->execute($prefix); };
  if ($@) {
    return http_response($env,400, pearlpbx_db()->errstr);
  }

  my $row = $sth->fetchrow_hashref;
  if ($row->{'dr_id'}) {
    if (( $row->{'dr_list_item'} eq $dlist_id ) or ( $row->{'dr_list_item'} == $dlist_id )) {
        return http_response($env,200,"ALREADY");
    }
    return http_response($env,200,"ALREADY_ANOTHER");
  }

  $sql = "insert into routing.directions (dr_list_item,dr_prefix,dr_prio) values (?,?,?)";
  $sth = pearlpbx_db()->prepare($sql);

  eval { $sth->execute($dlist_id,$prefix, $prio);};
  if ($@) {
    return http_response($env,400, pearlpbx_db()->errstr);
  }
  return http_response($env,200,"OK");

}

sub route_removeprefix {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;
  my $dr_id = $params->{'prefix'};

  unless ( defined ( $dr_id ) ) {
      return http_response($env,400,"prefix is not defined");
  }

  my $sql = "delete from routing.directions where dr_id=?";
  my $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute($dr_id); };
  if ($@) {
    return http_response($env,400, pearlpbx_db()->errstr);
  }
  return http_response($env,200,"OK");
}

=item B<route_addrouting>

    Adds routing steps to the route

=cut

sub route_addrouting {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;

  my $dlist_id = $params->{'dlist_id'};
  my $route_step = $params->{'route_step'};
  my $route_type = $params->{'route_type'};
  my $route_dest = $params->{'route_dest'};
  my $route_src  = $params->{'route_src'};

  if ( ! defined ( $dlist_id ) || ! defined ($route_step) ||
       ! defined ( $route_type ) || ! defined ($route_dest ) ||
       ! defined ( $route_src ) ) {
       return http_response($env,400,'One of the parameters is undefined');
  }

  my $sql = "insert into routing.route (route_direction_id, route_step, route_type, route_dest_id, route_sip_id )
    values (?,?,?,?,?) ";
  my $sth = pearlpbx_db()->prepare ($sql);
  if ($route_src =~ /^Anybody/i ) {
    $route_src = undef;
  }

  eval {
    $sth->execute ($dlist_id, $route_step, $route_type, $route_dest, $route_src);
  };
  if ( $@ ) {
    return http_response($env,400,pearlpbx_db()->errstr);
  }

  return http_response($env,200, "OK");

}

sub route_removerouting {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;
  my $route_id = $params->{'id'};

  unless ( defined ( $route_id ) ) {
      return http_response($env, 400, "nothing to remove");
  }

  my $sql = "delete from routing.route where route_id=?";
  my $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute($route_id); };
  if ($@) {
      return http_response($env,400,pearlpbx_db()->errstr);
  }
  return http_response($env,200,"OK");
}

sub route_savedirection {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;
  my $dlist_id = $params->{'route_id'};
  my $dlist_name = $params->{'route_name'};

  if ( ! defined ( $dlist_id ) || ! defined ( $dlist_name ) ) {
      return http_response($env,400,"required parameters is undefined");
  }

  my $sql = "update routing.directions_list set dlist_name=? where dlist_id=?";
  my $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute ($dlist_name, $dlist_id); };
  if ( $@ ) {
    return http_response($env,400,pearlpbx_db()->errstr);
  }
  return http_response($env,200,"OK");
}

sub route_removedirection {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $id = $params->{'id'};
    unless ( defined ( $id ) ) {
        return http_response($env, 400, "Required parameter id is not found");
    }

    my $sql  = "delete from routing.directions where dr_list_item=?";
    my $sql2 = "delete from routing.directions_list where dlist_id=?";
    my $sql3 = "delete from routing.permissions where direction_id=?";
    my $sql4 = "delete from routing.route where route_direction_id=?";

    my $perm = pearlpbx_db()->prepare($sql3);
    eval { $perm->execute ( $id ); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    my $rsth = pearlpbx_db()->prepare($sql4);
    eval { $rsth->execute ( $id ); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ( $id ); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    $sth = pearlpbx_db()->prepare($sql2);
    eval { $sth->execute ( $id ); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    return http_response($env,200,"OK");
}


sub route_adddirection {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $dlist_name = $params->{'dlist_name'};
    unless ( defined ( $dlist_name ) ) {
        return http_response($env,400,"Required parameter dlist_name is not found.");
    }

    my $sql = "insert into routing.directions_list (dlist_name) values (?) returning dlist_id";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ($dlist_name); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    my $row = $sth->fetchrow_hashref;
    unless ( $row ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    my $dlist_id = $row->{'dlist_id'};
    return http_response($env,200,"OK:".$dlist_id);
}

sub list_tgrpsAsOption {
  my $this = shift;

  my $sql = "select tgrp_id, tgrp_name from routing.trunkgroups order by tgrp_name";

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute(); };
  if ( $@ ) {
    print $this->{dbh}->errstr;
    return undef;
  }

  my $out = '';
  while ( my $row = $sth->fetchrow_hashref ) {
     $out .= '<option value="'.$row->{'tgrp_id'}.'">'.$row->{'tgrp_name'}.'</option>';
  }
  return $out;

}

sub list_contextsAsOption {
  my $this = shift;

  my $sql = "select id,context from extensions_conf where priority =1 and exten = '_X!' order by context";

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute(); };
  if ( $@ ) {
    print $this->{dbh}->errstr;
    return undef;
  }

  my $out = '';
  while ( my $row = $sth->fetchrow_hashref ) {
     $out .= '<option value="'.$row->{'id'}.'">'.$row->{'context'}.'</option>';
  }
  return $out;

}
sub checkroute {
  my ($this, $peername, $extension) = @_;
  my $route_type = {
        trunk => 'Транк',
        tgrp  => 'Транкгруппа',
        user  => 'Конечный пользователь',
        context => 'Сценарий IVR',
        lmask => 'Локальная маска',
    };

  my $out = '<ul>';
  $out .= "<li> Проверяю права доступа: ";
  my ($allow, $description) = $this->_get_permissions ($peername, $extension);
  unless ( defined ( $allow ) ) {
    $out .= "<span style=\"color: red;\">Нет прав доступа.</span> Причина: ".$description;
    $out .= "<br>";
    return $out;
  } else {
    $out .= "<span style=\"color: green;\">OK.</span>";
  }

  $out .= "<li>Конвертирую номер Б: ";
  my($result, $extension1, $description2) = $this->_convert_extension ($extension);
  # $extension = $extension1;
  unless ( defined ( $result ) ) {
    $out .= "<span style=\"color: red;\">Ошибка.</span> Причина: ".$description2;
    $out .= "<br>";
    return $out;
  } else {
    $out .= "<span style=\"color: green;\">ОК. Новый номер: $extension1 </span>";
  }

  my $tgrp_first;
  # Get dial route
  for ( my $current_try = 1 ; $current_try <= 5 ; $current_try++ ) {
    my ($result,$dst_type,$dst_str,$try) = $this->_get_dial_route( $peername, $extension, $current_try );
    unless ( defined($result) ) {
      $out .= "<li><span style=\"color: red;\">".$dst_type."</span>";
      return $out;
    }
    $current_try = $try;
    $out.="<li>"."Тип маршрутизации: ".$route_type->{$dst_type}.". Цель -> $dst_str";
    if ( $dst_type eq 'tgrp' ) {
      unless ( defined($tgrp_first) ) {
        $tgrp_first = $dst_str;
        next;
      }
      if ( $dst_str eq $tgrp_first ) {
        $current_try = $current_try + 1;
        $tgrp_first  = undef;
        next;
      }

    }    # End of (if tgrp)
  }    # End of for (1...5)
  $out .= "<li>Playback pearlpbx-nomorelines";
  return $out;

}


#
# С этой строки идут внутренние методы, которые повторяют agi-bin/NetSDS-route.pl ,
# В будущем, что бы не было копипаста надо удалить соответствующие методы из AGI-скрипта
# и использовать эти. Пока оставляю так как есть.
#
#     best, rad. 2012-09-23. use perl or die;

sub _get_permissions {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;

    my $sth = $this->{dbh}->prepare("select * from routing.get_permission (?,?)");

    eval { my $rv = $sth->execute( $peername, $exten ); };
    if ($@) {
        return (undef, $this->dbh->errstr);
    }
    my $result = $sth->fetchrow_hashref;
    my $perm   = $result->{'get_permission'};
    if ( $perm > 0 ) {
        $this->{dbh}->commit();
        return (1, "OK");
    } else {
        $this->{dbh}->rollback();
        return (undef, "$peername does not have permissions to $exten");
    }
}

sub _convert_extension {
  my $this = shift;
  my $input = shift;

  my $output = $input;
  my $result = undef;

    my $sth = $this->{dbh}->prepare ("select id,exten,operation,parameters,step from routing.convert_exten where ? ~ exten order by id,step");
    eval { my $rv = $sth->execute($input); };
    if ($@) {
        return (undef, $input, $this->{dbh}->errstr);
    }
    $result = $sth->fetchall_hashref ('id');
    unless ( defined ( $result ) ) {
        return (1, $input, 'OK');
    }

    if ( $result == {} ) {
        return (1, $input, 'OK');
    }

    foreach my $id ( sort keys %$result ) {
        my $operation = $result->{$id}->{'operation'};
        my $parameters = $result->{$id}->{'parameters'};
        my ($param1,$param2) = split (':',$parameters);
        if ($operation =~ /concat/ ) {
          # second param contains 'begin' or 'end'
          if ($param2 =~ /begin/) {
            $output = $param1 . $output;
          }
          if ($param2 =~ /end/ ) {
            $output = $output . $param1;
          }
        }
        if ($operation =~ /substr/ ) {
          # first param - position of beginning. Example: black : substr 2,3 = ack
          # second param - if empty substr till the end.

          unless ( $param1 ) {
            $param1 = 0;
          }
          unless ( $param2 ) {
            $output = substr($output,$param1);
          } else {
            $output = substr($output,$param1,$param2);
          }
        }
    }
    return (1,$output, 'OK');
}

sub _get_dial_route {
    my $this     = shift;
    my $peername = shift;
    my $exten    = shift;
    my $try      = shift;

    my $sth =
      $this->{dbh}->prepare("select * from routing.get_dial_route4 (?,?,?)");
    eval { my $rv = $sth->execute( $peername, $exten, $try ); };
    if ($@) {
      return (undef, $this->{dbh}->errstr, undef,undef);
    }
    my $result = $sth->fetchrow_hashref;
    return (1, $result->{'dst_type'}, $result->{'dst_str'}, $result->{'try'});
}

#
# Рисуем таблицу прав доступа
#
sub loadpermissions {
  my $this = shift;
  # Head
  my $errout = "<p style=\"color: red;\">%s</p>";
  my $out = "<table class=\"table table-bordered table-hover table-condensed\" id=\"pearlpbx_permissions_table\">";
  $out .= "<thead><tr>";
  my $directions = $this->_get_directions_list;
  unless ( defined ( $directions ) ) {
    return sprintf ( $errout, $this->{dbh}->errstr );
  }
  # X
  $out .= "<th colspan=2>".str_encode("Выделить все")."</th>";
  my $out2 .= "<tr><th colspan=2><input type=\"checkbox\" id=\"XYall\" onChange=\"pearlpbx_permissions_selectall()\"></th>";
  my $Xcount = @{$directions}; # Количество направлений
  foreach my $dir ( @{$directions} ) {
    $out .= "<th>".$dir->{'dlist_name'}."</th>";
    my $checkboxY = "<input type=\"checkbox\" id=\"Y".$dir->{'dlist_id'}."\" onChange=\"pearlpbx_permissions_set_y('Y".$dir->{'dlist_id'}."')\">";
    $out2 .= "<th style=\"background: grey;\">".$checkboxY."</th>";
  }
  $out2 .= "</tr>";
  $out .= "</tr>".$out2."</thead>";

  # Y
  my $sip_peers = $this->_get_sip_peers;
  unless ( defined ( $sip_peers )) {
    return sprintf ( $errout, $this->{dbh}->errstr );
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
  return $out;
}

sub _get_directions_list {
  my $this = shift;
  my $sql = "select dlist_id,dlist_name from routing.directions_list order by dlist_name";

  my $sth = $this->{dbh}->prepare($sql);
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
  my $this = shift;

  my $sql = "select id, name, comment from public.sip_peers order by name";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute();};
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

sub loadpermissionsJSON {
  my $this = shift;

  my $sql = "select direction_id, peer_id from routing.permissions order by id";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute; };
  if ( $@ ) {
    return $this->{dbh}->errstr;
  }

  my @rows;

  while (my $row = $sth->fetchrow_hashref) {
    push @rows,$row;
  }

  return encode_json (\@rows);
}

sub savepermissions {
  my ($this, $permissions) = @_;

  my (@matrix) = split (',',$permissions);
  my $mat = @matrix;
  my $count = 0;

  # $this->{dbh}->begin_work;

  foreach my $element ( @matrix ) {
    $element =~ /^X(\d+).Y(\d+)=(\d)$/;
    my $sip_peer = $1;
    my $direction_id = $2;
    my $val = $3;

    if ( ( $sip_peer > 0 ) and ( $direction_id > 0 ) ) {
      if ( $val > 0 ) {
        my $sql = "select * from routing.permissions where peer_id=? and direction_id=?";
        my $sth = $this->{dbh}->prepare($sql);
        eval { $sth->execute ($sip_peer,$direction_id); };
        if ($@) {
          return $this->{dbh}->errstr;
        }
        my $row = $sth->fetchrow_hashref;
        unless ( $row->{'id'} ) {
          $this->{dbh}->do ("insert into routing.permissions (peer_id,direction_id) values ($sip_peer,$direction_id)");
        }
      }
      if ( $val == 0 ){
        $this->{dbh}->do ("delete from routing.permissions where peer_id=".$sip_peer." and direction_id=".$direction_id);
      }
      $count++;
    }

  }
  $this->{dbh}->commit;
  return "OK:".$count;
}

sub loadcallerid {
  my $this = shift;

  my $sql = "select a.id, a.direction_id, b.dlist_name,  a.sip_id, c.name,  a.set_callerid from routing.callerid a, routing.directions_list b, public.sip_peers c   where a.direction_id=b.dlist_id and a.sip_id=c.id order by c.name, b.dlist_name;";
  my $sql2 = "select a.id, a.direction_id, b.dlist_name,  a.sip_id, a.set_callerid from routing.callerid a, routing.directions_list b where a.direction_id=b.dlist_id and a.sip_id is null order by b.dlist_name;";

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute; };
  if ( $@ ) {
    return $this->{dbh}->errstr;
  }

  my @rows;

  while (my $row = $sth->fetchrow_hashref) {
    $row->{'dlist_name'} = str_encode ($row->{'dlist_name'});
    push @rows,$row;
  }

  $sth = $this->{dbh}->prepare($sql2);
  eval { $sth->execute; };
  if ( $@ ) {
    return $this->{dbh}->errstr;
  }

  while (my $row = $sth->fetchrow_hashref) {
    $row->{'dlist_name'} = str_encode ($row->{'dlist_name'});
    $row->{'name'} = '';
    push @rows,$row;
  }

  return encode_json (\@rows);
}

sub setcallerid_remove_id {
  my ($this, $id) = @_;

  my $sql = "delete from routing.callerid where id=?";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($id);};
  if ($@) {
    return $this->{dbh}->errstr;
  }
  $this->{dbh}->commit;
  return "OK";
}

sub setcallerid_add {
  my ($this, $direction_id, $sip_id, $callerid ) = @_;

  if ($sip_id =~ /^Anybody/i ) {
    $sip_id = undef;
  }

  my $sql = "insert into routing.callerid (direction_id, sip_id, set_callerid) values (?,?,?)";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($direction_id, $sip_id, $callerid );};
  if ($@) {
    return $this->{dbh}->errstr;
  }
  $this->{dbh}->commit;
  return "OK";

}

sub load_convert_exten {
  my $this = shift;

  my $sql = "select * from routing.convert_exten order by exten,step";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute; };
  if ( $@ ) {
    return $this->{dbh}->errstr;
  }

  my @rows;

  while (my $row = $sth->fetchrow_hashref) {
    push @rows,$row;
  }

  return encode_json (\@rows);
}

sub add_convert_exten {
  my ($this, $exten, $operation, $param, $step ) = @_;

  my $sql = "insert into routing.convert_exten ( exten,operation,parameters,step ) values ( ?, ?, ?, ?)";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute ($exten,  $operation, $param, $step ); };
  if ( $@ ) {
    return $this->{dbh}->errstr;
  }
  $this->{dbh}->commit;
  return "OK";
}

sub remove_convert_exten {
  my ($this, $id) = @_;

  my $sql = "delete from routing.convert_exten where id=?";
  my $sth = $this->{dbh}->prepare ($sql);

  eval { $sth->execute ($id); };
  if ($@) { return $this->{dbh}->errstr; }

  $this->{dbh}->commit;
  return "OK";
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


