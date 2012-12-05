#===============================================================================
#
#         FILE:  SIP.pm
#
#  DESCRIPTION:  PearlPBX SIP management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  23.06.12
#      REVISION: 001 
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
use JSON;
use NetSDS::Util::String; 
use Data::Dumper; 

use version; our $VERSION = "1.00";
our @EXPORT_OK = qw();

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new($configfilename)> - class constructor

    my $object = PearlPBX::Report->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {

	my $class = shift; 
	
  my $conf = shift;

  my $this = {}; 

  unless ( defined ( $conf ) ) {
     $conf = '/etc/PearlPBX/asterisk-router.conf';
  }

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
    return undef;
  }

  my %cf_hash = $config->getall or ();
  $this->{conf} = \%cf_hash;
  $this->{dbh} = undef;     # DB handler 
  $this->{error} = undef;   # Error description string    

	bless ( $this,$class ); 
	return $this;

};

#***********************************************************************
=head1 OBJECT METHODS

=over

=item B<db_connect(...)> - соединяется с базой данных. 
Возвращает undef в случае неуспеха или true если ОК.
DBH хранит в this->{dbh};  

=cut

#-----------------------------------------------------------------------

sub db_connect {
	my $this = shift; 
  
    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->{error} = "Can't find \"db main->dsn\" in configuration.";
        return undef;  
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->{error} = "Can't find \"db main->login\" in configuraion.";
        return undef;
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->{error} = "Can't find \"db main->password\" in configuraion.";
        return undef;
    }

    my $dsn    = $this->{conf}->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->{conf}->{'db'}->{'main'}->{'login'};
    my $passwd = $this->{conf}->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->{dbh} or !$this->{dbh}->ping ) {
        $this->{dbh} = 
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1, AutoCommit => 0 } );
    }

    if ( !$this->{dbh} ) {
        $this->{error} = "Cant connect to DBMS!";
        return undef;
    }

    return 1;
};
=item B<list_internal> 

 возвращает HTML представление списка внутренних пользователей

=cut 
sub list_internal { 
	my $this = shift;
	my $sql = "select id,comment,name from public.sip_peers where name ~ E'2\\\\d\\\\d' order by name";

	return $this->_list($sql,undef);
}

sub list_internalAsOption { 
  my $this = shift;
  my $sql = "select id,comment,name from public.sip_peers where name ~ E'2\\\\d\\\\d' order by name";

  return $this->_listAsOption($sql);  
}

sub list_internalAsJSON { 
  my $this = shift; 
  my $sql = "select id,comment,name from public.sip_peers where name ~ E'2\\\\d\\\\d' order by name";

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
  my $sql = "select id,comment,name from public.sip_peers where name ~ E'2\\\\d\\\\d' order by name";

  return $this->_listAsOptionIdValue($sql);  
}

=item B<list_external> 

 возвращает HTML представление списка внешних транков 

=cut 
sub list_external { 
	my $this = shift; 
	my $sql = "select id,name,comment from public.sip_peers where name !~ E'2\\\\d\\\\d' order by name"; 

  return $this->_list($sql,1); 
}
sub list_externalAsJSON { 
  my $this = shift; 
  my $sql = "select id,comment,name from public.sip_peers where name !~ E'2\\\\d\\\\d' order by name";

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
  my $sql = "select id,name,comment from public.sip_peers where name !~ E'2\\\\d\\\\d' order by name"; 

  return $this->_listAsOption($sql); 
}
sub list_externalAsOptionIdValue { 
  my $this = shift; 
  my $sql = "select id,name,comment from public.sip_peers where name !~ E'2\\\\d\\\\d' order by name"; 

  return $this->_listAsOptionIdValue($sql); 
}

sub _list { 
	my ($this, $sql, $external) = @_; 

  my $js_func_name = sub { 
    return 'pearlpbx_sip_load_external_id' if $external;
    return 'pearlpbx_sip_load_id'; 
  }; 

  my $dialog_name = sub { 
    return 'pearlpbx_sip_edit_peer' if $external;
    return 'pearlpbx_sip_edit_user'; 
  };

	my $sth = $this->{dbh}->prepare($sql); 
	eval { $sth->execute(); }; 
	if ( $@ ) {
	  print $this->{dbh}->errstr; 
		return undef; 
	}

	my $out = '<ul class="nav nav-tabs">';
  while ( my $row = $sth->fetchrow_hashref ) { 
		 unless ( defined ( $row->{'comment'} ) ) { 
		 	$row->{'comment'} = ''; 
		 } 
	   $out .= '<li><a href="#'.&$dialog_name.'" data-toggle="modal" onClick="'.&$js_func_name.'('.$row->{'id'}.')">'.$row->{'comment'}.'&lt;'.$row->{'name'}.'&gt;'.'</a></li>';
	}		 
  $out .= "</ul>";
	return $out; 
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

=item B<newsecret>

 Генерирует новый пароль и возвращает его 

=cut 

sub newsecret { 
  my $this = shift; 

  return `pwgen -c 16`;

}

=item B<adduser>

 Добавляет нового пользователя в public.sip_peers. 
 Простой метод. Сложный будет доступен чуть позже, для advanced administrators и подозреваю, 
 что за деньги. Ибо для SMB-сектора текущего метода должно хватить.  

=cut 

sub adduser { 
  my ($this, $params) = @_;

  my $sql  = "insert into public.sip_peers (name, comment, secret, host, context ) values (?,?,?,?,?) returning id"; 
  my $sql2 = "insert into integration.workplaces (sip_id, teletype, autoprovision, mac_addr_tel, integration_type, tcp_port, ip_addr_tel, ip_addr_pc ) 
    values (?,?,?,?,?,?,?,?)"; 

  unless ( defined ( $params->{'extension'} ) or 
         defined ( $params->{'comment'} ) or 
         defined ( $params->{'secret'} ) ) { 
    return "ERROR";
  }

  my $sth  = $this->{dbh}->prepare($sql);

  eval { 
    $sth->execute( 
      $params->{'extension'},
      $params->{'comment'},
      $params->{'secret'},
      'dynamic',
      'default',
    ); 
  };

  if ( $@ ) {
    return "ERROR:". $this->{dbh}->errstr;  
  }

  my $row = $sth->fetchrow_hashref; 
  my $sip_id = $row->{'id'};

  
  my $sth2 = $this->{dbh}->prepare($sql2);
  my $teletype = $params->{'terminal'};
  my $autoprovision = 'true';

  unless ( defined ( $params->{'terminal'})) { 
    $teletype = "softphone"; 
    $autoprovision = 'false';  
  } 

  $params->{'tcp_port'} = undef if $params->{'tcp_port'} eq ''; 

  eval { 
    $sth2->execute( 
      $sip_id, $teletype, $autoprovision, $params->{'macaddr'}, 
      $params->{'integration_type'}, $params->{'tcp_port'}, 
      $params->{'ip_addr_tel'}, $params->{'ip_addr_pc'}
    ); 
  };

  if ( $@ ) {
    return "ERROR:". $this->{dbh}->errstr;  
  }

  eval { $this->{dbh}->commit;};
  if ( $@ ) {
    return "ERROR:". $this->{dbh}->errstr;  
  }
  return "OK";

}



sub getuser { 
  my ($this,$id) = @_; 

  my $sql = "select a.id, a.name as extension, a.comment, a.secret,
  b.teletype, b.mac_addr_tel, b.integration_type, b.tcp_port,
  b.ip_addr_tel, b.ip_addr_pc from public.sip_peers a,
  integration.workplaces b where a.id=? and a.id=b.sip_id;";

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($id); }; 
  if ( $@ ) {
    return "ERROR:". $this->{dbh}->errstr;  
  }
  my $row = $sth->fetchrow_hashref; 
  $row->{'comment'} = str_encode($row->{'comment'}); 
  return encode_json($row);

}

sub getpeer { 
  my ($this,$id) = @_; 

  my $sql = "select id, name, comment, secret, context, host, insecure, nat, permit, deny, qualify, 
  type, username, ipaddr, \"call-limit\" as cl  
  from public.sip_peers where id = ?"; 

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($id); }; 
  if ( $@ ) {
    return "ERROR:". $this->{dbh}->errstr;  
  }
  my $row = $sth->fetchrow_hashref; 
  $row->{'comment'} = str_encode($row->{'comment'}); 

  my $username = $row->{'username'};

  $sql = "select id, var_val,commented from public.sip_conf where var_name='register' and var_val like '".$username.":%' "; 
  $sth = $this->{dbh}->prepare($sql); 
  eval { $sth->execute();}; 
  if ($@) { 
    return "ERROR:". $this->{dbh}->errstr; 
  } 
  my $row2 = $sth->fetchrow_hashref; 
  $row->{'regstr'} = $row2->{'var_val'}; 
  $row->{'regstr_id'} = $row2->{'id'};
  $row->{'regstr_commented'} = $row2->{'commented'};  

  return encode_json($row);

}


sub setuser {

my ($this, $params) = @_;

  my $sql  = "update public.sip_peers set comment=?, secret=? where id=? "; 
  my $sql2 = "update integration.workplaces set teletype=?, autoprovision=?, mac_addr_tel=?, 
                integration_type=?,tcp_port=?,ip_addr_tel=?,ip_addr_pc=? 
                  where sip_id=?"; 

  my $autoprovision = 'true'; 

  if ( $params->{'terminal'} =~ /softphone/ ) { 
      $autoprovision = 'false';
  }

  unless ( defined ( $params->{'comment'} ) or defined ( $params->{'secret'} ) ) { 
    return "ERROR";
  }

  my $sth  = $this->{dbh}->prepare($sql);
  my $sth2 = $this->{dbh}->prepare($sql2);

  $params->{'tcp_port'} = undef if $params->{'tcp_port'} eq ''; 

  eval {$sth->execute($params->{'comment'}, $params->{'secret'}, $params->{'id'});};
  if ( $@ ) { return "ERROR:". $this->{dbh}->errstr; }

  eval { $sth2->execute($params->{'terminal'}, $autoprovision, $params->{'macaddr'}, 
    $params->{'integration_type'}, $params->{'tcp_port'}, 
    $params->{'ip_addr_tel'}, $params->{'ip_addr_pc'},
    $params->{'id'} );
  }; 
  if ( $@ ) { return "ERROR:". $this->{dbh}->errstr; }

  $this->{dbh}->commit;
  return "OK";

}

sub setpeer { 
  my ($this, $params) = @_; 

  my $sip_id = $params->{'sip_id'}; 
  my $sip_comment = $params->{'sip_comment'}; 
  my $sip_name = $params->{'sip_name'};  
  my $sip_username = $params->{'sip_username'};  
  my $sip_secret = $params->{'sip_secret'}; 
  my $sip_remote_register = $params->{'sip_remote_register'}; 
  my $sip_regstr_id = $params->{'sip_remote_regstr_id'};  
  my $sip_remote_regstr = $params->{'sip_remote_regstr'}; 
  my $sip_local_register = $params->{'sip_local_register'}; 
  my $sip_nat = $params->{'sip_nat'};  
  my $sip_ipaddr = $params->{'sip_ipaddr'}; 
  my $sip_call_limit = $params->{'sip_call_limit'}; 
  if ($sip_call_limit eq '') { $sip_call_limit = 2; }

  my $sip_host = 'dynamic'; 
  my $sip_type = 'friend'; 
  my $sip_insecure = ''; 
  my $sip_permit = ''; 
  my $sip_deny = ''; 


  if ($sip_nat eq 'true') { $sip_nat = 'yes'; } else { $sip_nat = 'no'; }  
  if ($sip_local_register eq 'false') { 
    $sip_insecure = 'invite,port'; 
    $sip_permit = $sip_ipaddr."/255.255.255.255"; 
    $sip_deny = "0.0.0.0/0.0.0.0"; 
    $sip_type = "peer"; 
  }

  my @sip_params; 
  my $sql; 


  if ($sip_id ne '') { 
    $sql = "update public.sip_peers set name=?,username=?,secret=?,
                      comment=?,nat=?,\"call-limit\"=?,
                      type=?,host=?,permit=?,deny=?,ipaddr=?,insecure=? where id=?"; 
    push @sip_params, $sip_name, $sip_username, $sip_secret, $sip_comment, $sip_nat, 
        $sip_call_limit, $sip_type, $sip_host, $sip_permit, $sip_deny, 
        $sip_ipaddr, $sip_insecure, $sip_id ; 
  } 
  if ($sip_id eq '' ) { 
    $sql = "insert into public.sip_peers (name,username,secret,comment,nat,\"call-limit\",
    type,host,permit,deny,ipaddr,insecure) values (?,?,?,?,?,?,?,?,?,?,?,?)"; 

    push @sip_params, $sip_name, $sip_username, $sip_secret, $sip_comment, $sip_nat, 
        $sip_call_limit, $sip_type, $sip_host, $sip_permit, $sip_deny, 
        $sip_ipaddr, $sip_insecure;
     
  }
  my $sth = $this->{dbh}->prepare($sql); 

  eval { $sth->execute ( @sip_params ); };

  if ( $@ ) { return "ERROR:". $this->{dbh}->errstr; }

  my $doreg = undef; 

  if ( $sip_remote_register eq 'true') { 
    $doreg = $this->_add_or_replace_regstr ($sip_remote_regstr, $sip_regstr_id); 
  } else { 
    $doreg = $this->_remove_regstr ($sip_regstr_id); 
  }

  if ($doreg =~ /^ERROR/ ) { return $doreg; }

  $this->{dbh}->commit; 
  return "OK"; 
}

sub _add_or_replace_regstr { 
  my ($this, $regstr, $regstr_id) = @_; 

  my $sql = ''; 

  if ($regstr_id eq '') {
    $sql = "select max(var_metric)+1 as next_metric from public.sip_conf"; 
    my $row = $this->{'dbh'}->selectrow_hashref($sql); 
    $sql = "insert into public.sip_conf ( cat_metric, var_metric, commented, filename, category, var_name, var_val ) 
      values ( 0,?,0,'sip.conf','general','register',?)"; 
    my $sth = $this->{dbh}->prepare ($sql); 
    eval { $sth->execute ($row->{'next_metric'}, $regstr ); }; 
    if ( $@ ) { return "ERROR:". $this->{dbh}->errstr; }
    return "OK"; 
  }
  
  $sql = "update public.sip_conf set var_val=?, commented=0 where id=?"; 
  my $sth = $this->{dbh}->prepare ($sql); 
  eval { $sth->execute ($regstr, $regstr_id ); }; 
  if ( $@ ) { return "ERROR:". $this->{dbh}->errstr; }
  return "OK"; 

}

sub _remove_regstr { 
  my ($this, $sip_regstr_id) = @_; 

  my $sql = "update public.sip_conf set commented = 1 where id = ?"; 
  my $sth = $this->{dbh}->prepare ($sql); 
  eval { $sth->execute ( $sip_regstr_id );  }; 
  if ( $@ ) { return "ERROR:". $this->{dbh}->errstr; }

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


