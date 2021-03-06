# ===============================================================================
#
#         FILE:  SIP.pm
#
#  DESCRIPTION:  PearlPBX SIP management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@pearlpbx.com>
#      COMPANY:  PearlPBX
#      CREATED:  23.06.2012
#     MODIFIED:  20.07.2017
#
#===============================================================================
=head1 NAME

PearlPBX::SIP

=head1 SYNOPSIS

	use PearlPBX::SIP;

=cut

package PearlPBX::SIP;

use 5.8.0;
use strict;
use warnings;

use DBI;
use Config::General;
use JSON::XS;
use NetSDS::Util::String;
use Data::Dumper;

use PearlPBX::Config qw/conf/;
use PearlPBX::DB qw/pearlpbx_db/;
use PearlPBX::HttpUtils qw/http_response/;

use Exporter;
use parent qw(Exporter);

our @EXPORT = qw (
    sipdb_monitor_get
    sipdb_list_internal
    sipdb_list_external
    sipdb_getuser
    newsecret
    sipdb_setuser
    sipdb_adduser
    sipdb_deluser
    sipdb_setpeer
    sipdb_getpeer
);

=item B<sipdb_monitor_get>

    Returns count of sip peers in the database

=cut

sub sipdb_monitor_get {
    my $env = shift;
    my $req = Plack::Request->new($env);

    my $sql = "select count(id) as monitor from public.sip_peers";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute(); };
    if ( $@ ) {
        my $res = $req->new_response(400);
        $res->body (pearlpbx_db()->errstr);
        $res->finalize;
    }

    my $row = $sth->fetchrow_hashref;
    my $monitor = $row->{'monitor'};
    unless ( defined ( $monitor )) { $monitor = "undef"; }

    my $res = $req->new_response(200);
    $res->body($monitor);
    $res->finalize;

}

=item B<sipdb_list_internal>

 возвращает HTML представление списка внутренних пользователей

=cut

sub sipdb_list_internal {
	my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $format = $params->{'format'} // 'HTML';

    my $sql = "select a.id as id, a.comment as comment, a.name as name, b.teletype as termtype from public.sip_peers a, integration.workplaces b where b.sip_id = a.id order by a.name";

    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute(); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    if ($format eq 'OPTION') {
        return sipdb_list_options($env, $sth, undef );
    } elsif ($format eq 'OptionIdValue') {
        sipdb_list_optionIdValue($env, $sth, undef);
    }else {
        sipdb_list_html($env, $sth, undef );
    }
}

sub sipdb_list_external {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $format = $params->{'format'} // 'HTML';

    my $sql = "select id, comment, name, ipaddr from public.sip_peers where id not in ( select sip_id from integration.workplaces ) order by name";

    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute(); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    if ($format eq 'OptionIdValue') {
        return sipdb_list_optionIdValue($env,$sth,1);
    }
    sipdb_list_html($env, $sth, 1 );
}

sub sipdb_list_optionIdValue {
    my ($env, $sth, $external ) = @_;

    my $out = '';
    while ( my $row = $sth->fetchrow_hashref ) {
        unless ( defined ( $row->{'comment'} ) ) {
            $row->{'comment'} = '';
        }
        $out .= '<option value="'.$row->{'id'}.'">'.$row->{'comment'}.'&lt;'.$row->{'name'}.'&gt;</option>';
    }
    return http_response($env,200,$out);
}

=item B<sipdb_list_options>

    Returns list of SIP peers as select options

=cut

sub sipdb_list_options {
    my ($env, $sth, $external ) = @_;

    my $out = '';
    while ( my $row = $sth->fetchrow_hashref ) {
        unless ( defined ( $row->{'comment'} ) ) {
            $row->{'comment'} = '';
        }
        $out .= '<option value="'.$row->{'name'}.'">'.$row->{'comment'}.'&lt;'.$row->{'name'}.'&gt;</option>';
    }
    return http_response($env,200,$out);
}


=item B<sipdb_list_html>

    Returns HTML-view of SIP peers list depends on internal/external

=cut

sub sipdb_list_html {
	my ($env, $sth, $external) = @_;

    my $js_func_name = $external ? 'pearlpbx_sip_load_external_id' : 'pearlpbx_sip_load_id';
    my $dialog_name  = $external ? 'pearlpbx_sip_edit_peer'        : 'pearlpbx_sip_edit_user';

    my $req = Plack::Request->new($env);


    my $out  = '<table class="table table-bordered table-hover">';
    $out .= $external ? '<tr><th>Connection description</th><th>Trunk name</th><th>Trunk IP</th></tr>' : '<tr><th>Name</th><th>Extension</th><th>Terminal type</th></tr>';

    my $row;
    while ( my $row = $sth->fetchrow_hashref ) {
        my $comment = $row->{'comment'} // '';
        my $termtype = $row->{'termtype'} // $row->{'ipaddr'};

	    $out .= '<tr><td><a href="#'.$dialog_name.'" data-toggle="modal" onClick="'.$js_func_name.'('.$row->{'id'}.')">'.$comment.'&lt;'.$row->{'name'}.'&gt;'.'</a></td>';
        $out .= '<td>'.$row->{'name'}.'</td>';
        $out .= '<td>'.$termtype.'</td></tr>';
	}
    $out .= "</table>";

    return http_response($env,200,$out);
}

=item B<sipdb_deluser>

    Delete SIP user by sip_id

=cut

sub sipdb_deluser {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $id = $params->{'id'};

    unless ( defined ( $id ) ) {
        return http_response($env, 400, "There is no ID to delete the user");
    }

    my $hash_ref = pearlpbx_db()->selectrow_hashref("select id from sip_peers where id='".$id."'");
    unless ( defined ( $hash_ref->{'id'} ) ) {
        return http_response($env, 400, "User not found to delete");
    }
    pearlpbx_db()->do("delete from routing.permissions where peer_id=$id");
    pearlpbx_db()->do("delete from integration.workplaces where sip_id=$id");
    pearlpbx_db()->do("delete from public.sip_peers where id=$id");
    pearlpbx_db()->commit;

    return http_response ( $env, 200, "OK");
}

=item B<sipdb_getuser>

    Return SIPuser by ID

=cut

sub sipdb_getuser {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;

    my $sipdb_id = $params->{'id'};
    unless ( defined ( $sipdb_id ) ) {
        my $res = $req->new_response(400);
        $res->body("getuser required parameter id");
        $res->finalize;
        return;
    }

    my $sql = "select a.id, a.name as extension, a.comment, a.secret,
      b.teletype, b.mac_addr_tel, b.integration_type, b.tcp_port,
      b.ip_addr_tel, b.ip_addr_pc from public.sip_peers a,
      integration.workplaces b where a.id=? and a.id=b.sip_id;";

    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($sipdb_id); };
    if ( $@ ) {
        my $res = $req->new_response(400);
        $res->body(pearlpbx_db()->errstr);
        $res->finalize;
        return;
    }
    my $row = $sth->fetchrow_hashref;
    $row->{'comment'} = str_encode($row->{'comment'});
    my $res = $req->new_response(200);
    $res->body( encode_json($row) );
    $res->finalize;

}

=item B<newsecret>

    Returns new password

=cut


sub newsecret {
  my $env = shift;

  my $pw = `pwgen -c 16 -s`;
  chomp $pw;

  return http_response($env,200,$pw);
}

=item B<sipdb_setuser>

    Update user's properties in the database

=cut

sub sipdb_setuser {

    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;

    my $sql  = "update public.sip_peers set comment=?, secret=? where id=? ";
    my $sql2 = "update integration.workplaces set teletype=?, autoprovision=?, mac_addr_tel=?,
                integration_type=? where sip_id=?";

    my $autoprovision = 'true';

    if ( ( $params->{'terminal'} eq 'softphone' ) || ( $params->{'terminal'} eq 'oldhardphone' ) ) {
      $autoprovision = 'false';
    }

    unless ( defined ( $params->{'comment'} ) or defined ( $params->{'secret'} ) ) {
        return http_response($env,400,'setuser required mandatory parameters:  comment, secret');
    }

    my $sth  = pearlpbx_db()->prepare($sql);
    my $sth2 = pearlpbx_db()->prepare($sql2);

    eval {$sth->execute($params->{'comment'}, $params->{'secret'}, $params->{'id'});};
    if ( $@ ) { return http_response($env,400,pearlpbx_db()->errstr); }

    eval { $sth2->execute($params->{'terminal'}, $autoprovision, $params->{'macaddr'},
        $params->{'integration_type'}, $params->{'id'} );
    };
    if ( $@ ) { return http_response($env,400,pearlpbx_db()->errstr); }

    pearlpbx_db()->commit;
    return http_response($env,200,"OK");

}

=item B<sipdb_adduser>

    Add simple information about SIP user to the database.

=cut

sub sipdb_adduser {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;

    my $sql  = "insert into public.sip_peers (name, comment, secret, type, host, context ) values (?,?,?,?,?,?) returning id";
    my $sql2 = "insert into integration.workplaces (sip_id, teletype, autoprovision, mac_addr_tel) values (?,?,?,?)";

    unless ( defined ( $params->{'extension'} ) or
             defined ( $params->{'comment'} ) or
             defined ( $params->{'secret'} ) ) {
       return http_response($env,400,'Invalid one of parameters: extension,comment,secret');
    }

    my $sth  = pearlpbx_db()->prepare($sql);

    eval {
        $sth->execute(
          $params->{'extension'},
          $params->{'comment'},
          $params->{'secret'},
          'friend',
          'dynamic',
          'default',
        );
    };

    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    my $row = $sth->fetchrow_hashref;
    my $sip_id = $row->{'id'};

    my $sth2 = pearlpbx_db()->prepare($sql2);
    my $teletype = $params->{'terminal'};
    my $autoprovision = 'true';

    if ( !defined ( $params->{'terminal'})) {
      $teletype = "softphone";
    }

    if ( ( $params->{'terminal'} eq 'softphone' ) || ( $params->{'terminal'} eq 'oldhardphone' ) ) {
      $autoprovision = 'false';
    }

    eval {
      $sth2->execute(
      $sip_id, $teletype, $autoprovision, $params->{'macaddr'},
    ); };

    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    eval { pearlpbx_db()->commit; };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    return http_response($env,200,"OK");

}

=item B<sipdb_setpeer>

    Update or add SIP peer information to the database

=cut

sub sipdb_setpeer {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;

    my $sip_id = $params->{'sip_id'};
    my $sip_comment = $params->{'sip_comment'};
    my $sip_name = $params->{'sip_name'};
    my $sip_username = $params->{'sip_username'};
    my $sip_defaultuser = $params->{'sip_username'};
    my $sip_secret = $params->{'sip_secret'};
    my $sip_remote_register = $params->{'sip_remote_register'};
    my $sip_regstr_id = $params->{'sip_remote_regstr_id'};
    my $sip_remote_regstr = $params->{'sip_remote_regstr'};
    my $sip_local_register = $params->{'sip_local_register'};
    my $sip_nat = $params->{'sip_nat'};
    my $sip_ipaddr = $params->{'sip_ipaddr'};
    my $sip_call_limit = $params->{'sip_call_limit'};
    if ($sip_call_limit eq '') { $sip_call_limit = 2; }

    my $sip_host = $sip_ipaddr;
	if ($sip_ipaddr eq '') {
		$sip_host = 'dynamic';
	}

    my $sip_type = 'friend';
    my $sip_insecure = '';
    my $sip_permit = '';
    my $sip_deny = '';

    if ($sip_nat eq 'true') { $sip_nat = 'force_rport,comedia'; } else { $sip_nat = 'no'; }
    if ($sip_local_register eq 'false') {
        $sip_insecure = 'invite,port';
        $sip_permit = $sip_ipaddr;
        $sip_deny = "0.0.0.0";
        $sip_type = "peer";
    }

    my @sip_params;
    my $sql;

    if ($sip_id ne '') {
        $sql = "update public.sip_peers set name=?,fromuser=?,defaultuser=?,secret=?,
                      comment=?,nat=?,\"call-limit\"=?,
                      type=?,host=?,permit=?,deny=?,ipaddr=?,insecure=? where id=?";
        push @sip_params, $sip_name, $sip_username, $sip_defaultuser, $sip_secret, $sip_comment, $sip_nat,
            $sip_call_limit, $sip_type, $sip_host, $sip_permit, $sip_deny,
            $sip_ipaddr, $sip_insecure, $sip_id ;
    } else {

        $sql = "insert into public.sip_peers (name,fromuser,defaultuser,secret,comment,nat,\"call-limit\",
            type,host,permit,deny,ipaddr,insecure) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";

        push @sip_params, $sip_name, $sip_username, $sip_defaultuser, $sip_secret, $sip_comment, $sip_nat,
            $sip_call_limit, $sip_type, $sip_host, $sip_permit, $sip_deny,
            $sip_ipaddr, $sip_insecure;
    }

    my $sth = pearlpbx_db()->prepare($sql);

    eval { $sth->execute ( @sip_params ); };

    if ( $@ ) { return http_response($env,400,pearlpbx_db()->errstr); }

    my $doreg = '';

    if ( $sip_remote_register eq 'true') {
         $doreg = _add_or_replace_regstr ($sip_remote_regstr, $sip_regstr_id);
    } else {
	    if ( $sip_regstr_id ne "" ) {
        if ( ($sip_regstr_id+0) > 0) {
			  $doreg = _remove_regstr ($sip_regstr_id);
		  }
		}
    }

    unless ( defined ( $doreg ) ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    };
    pearlpbx_db()->commit;
    return http_response($env,200,"OK");

}

sub _add_or_replace_regstr {
  my ( $regstr, $regstr_id) = @_;

  my $sql = '';

  if ($regstr_id eq '') {
    $sql = "select max(var_metric)+1 as next_metric from public.sip_conf";
    my $row = pearlpbx_db()->selectrow_hashref($sql);
    $sql = "insert into public.sip_conf ( cat_metric, var_metric, commented, filename, category, var_name, var_val )
      values ( 0,?,0,'sip.conf','general','register',?)";
    my $sth = pearlpbx_db()->prepare ($sql);
    eval { $sth->execute ($row->{'next_metric'}, $regstr ); };
    if ( $@ ) { return undef; }
    return 1;
  }

  $sql = "update public.sip_conf set var_val=?, commented=0 where id=?";
  my $sth = pearlpbx_db()->prepare ($sql);
  eval { $sth->execute ($regstr, $regstr_id ); };
  if ( $@ ) { return undef; }
  return 1;

}

sub _remove_regstr {
  my $sip_regstr_id = shift;

  my $sql = "update public.sip_conf set commented = 1 where id = ?";
  my $sth = pearlpbx_db()->prepare ($sql);
  eval { $sth->execute ( $sip_regstr_id );  };
  if ( $@ ) { return undef; }
  return 1;

}

=item B<sipdb_getpeer>

    Find and returns SIP peer properties including register string from sip_conf

=cut

sub sipdb_getpeer {
  my $env = shift;
  my $req = Plack::Request->new($env);
  my $params = $req->parameters;
  my $id = $params->{'id'};

  unless ( defined ( $id ) ) {
      return http_response($env,400,"No ID parameter in request");
  }

  my $sql = "select id, name, comment, secret, context, host, insecure, nat, permit, deny, qualify,
       type, fromuser, defaultuser, ipaddr, \"call-limit\" as cl
       from public.sip_peers where id = ?";

  my $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute($id); };
  if ( $@ ) {
    return http_response($env,400, pearlpbx_db()->errstr);
  }

  my $row = $sth->fetchrow_hashref;
  $row->{'comment'} = str_encode($row->{'comment'});

  my $fromuser = $row->{'fromuser'};
  $row->{'username'} = $row->{'fromuser'};

  $sql = "select id, var_val,commented from public.sip_conf where var_name='register' and var_val like '".$fromuser.":%' ";
  $sth = pearlpbx_db()->prepare($sql);
  eval { $sth->execute();};
  if ($@) {
    return http_response($env,400, pearlpbx_db()->errstr);
  }
  my $row2 = $sth->fetchrow_hashref;
  $row->{'regstr'} = $row2->{'var_val'};
  $row->{'regstr_id'} = $row2->{'id'};
  $row->{'regstr_commented'} = $row2->{'commented'};

  return http_response($env, 200, encode_json($row));

}


###### Old shit. Remove it. ######


sub list_internalAsOption {
  my $this = shift;
  my $sql = "select a.id as id, a.comment as comment, a.name as name from public.sip_peers a, integration.workplaces b where b.sip_id = a.id order by a.name";
  return $this->_listAsOption($sql);
}

sub list_internalAsJSON {
  my $this = shift;
  #my $sql = "select id,comment,name from public.sip_peers where name ~ E'^2\\\\d\\\\d\$' order by name";
  my $sql = "select a.id as id, a.comment as comment, a.name as name from public.sip_peers a, integration.workplaces b where b.sip_id = a.id order by a.name";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute();};
  if ($@) {
    return $this->{dbh}->errstr;
  }
  my @rows;
  while ( my $row = $sth->fetchrow_hashref) {
    $row->{'comment'} = str_encode($row->{'comment'});
    push @rows, $row;
  }
  return encode_json(\@rows);

}
sub list_internalAsOptionIdValue {
  my $this = shift;
#  my $sql = "select id,comment,name from public.sip_peers where name ~ E'^2\\\\d\\\\d\$' order by name";
  my $sql = "select a.id as id, a.comment as comment, a.name as name from public.sip_peers a, integration.workplaces b where b.sip_id = a.id order by a.name";

  return $this->_listAsOptionIdValue($sql);
}

sub list_externalAsJSON {
  my $this = shift;
  my $sql = "select id, comment, name from public.sip_peers where id not in ( select sip_id from integration.workplaces ) order by name";

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute();};
  if ($@) {
    return $this->{dbh}->errstr;
  }
  my @rows;
  while ( my $row = $sth->fetchrow_hashref) {
    $row->{'comment'} = str_encode($row->{'comment'});
    push @rows, $row;
  }
  return encode_json(\@rows);

}


sub list_externalAsOption {
  my $this = shift;
  my $sql = "select id, comment, name from public.sip_peers where id not in ( select sip_id from integration.workplaces ) order by name";

  return $this->_listAsOption($sql);
}
sub list_externalAsOptionIdValue {
  my $this = shift;
  my $sql = "select id, comment, name from public.sip_peers where id not in ( select sip_id from integration.workplaces ) order by name";

  return $this->_listAsOptionIdValue($sql);
}

sub _listAsOption {
  my ($this, $sql) = @_;

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute(); };
  if ( $@ ) {
    print $this->{dbh}->errstr;
    return undef;
  }

  my $out = '';
  while ( my $row = $sth->fetchrow_hashref ) {
     unless ( defined ( $row->{'comment'} ) ) {
      $row->{'comment'} = '';
     }
     $out .= '<option value="'.$row->{'name'}.'">'.$row->{'comment'}.'&lt;'.$row->{'name'}.'&gt;</option>';
  }
  return $out;
}



sub _listAsOptionIdValue {
  my ($this, $sql) = @_;

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute(); };
  if ( $@ ) {
    print $this->{dbh}->errstr;
    return undef;
  }

  my $out = '';
  while ( my $row = $sth->fetchrow_hashref ) {
     unless ( defined ( $row->{'comment'} ) ) {
      $row->{'comment'} = '';
     }
     $out .= '<option value="'.$row->{'id'}.'">'.$row->{'comment'}.'&lt;'.$row->{'name'}.'&gt;</option>';
  }
  return $out;
}


=item B<list_internal_free>

Возвращает список свободных внутренних номеров в виде списка option for select

DEPRECATED!!!

=cut

sub list_internal_free {
  my $this = shift;

  my $sql = 'select freename from generate_series (200,299,1) as freename where freename::text not in ( select name from public.sip_peers);';
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute(); };
  if ( $@ ) {
    print $this->{dbh}->errstr;
    return undef;
  }
  my $out = '';
  while ( my $row = $sth->fetchrow_hashref ) {
    $out .= '<option value="'.$row->{'freename'}.'">'.$row->{'freename'}.'</option>';
  }
  return $out;

}


sub monitor_get_sip_db {
  my $this = shift;

  my $sql = "select count(id) as monitor from public.sip_peers";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute(); };
  if ( $@ ) { return $this->{dbh}->errstr; }
  my $row = $sth->fetchrow_hashref;
  my $monitor = $row->{'monitor'};
  unless ( defined ( $monitor )) { $monitor = "undef"; }
  return $monitor;

}

sub tftp_reload {
  my $this = shift;

  system ('/usr/bin/PearlPBX-tftpprovisor.pl','--fromdb') or return $?;


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


