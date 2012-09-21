#===============================================================================
#
#         FILE:  Route.pm
#
#  DESCRIPTION:  PearlPBX Route management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  23.06.12
#      REVISION: 001 
#===============================================================================
=head1 NAME

PearlPBX::Route

=head1 SYNOPSIS

	use PearlPBX::Route;

=cut

package PearlPBX::Route;

use 5.8.0;
use strict;
use warnings;

use DBI;
use Config::General; 
use JSON;
use NetSDS::Util::String; 

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
sub list_directions_tab { 
	my $this = shift;
	my $sql = "select dlist_id,dlist_name from routing.directions_list order by dlist_name";

	my $sth = $this->{dbh}->prepare($sql); 
	eval { $sth->execute(); }; 
	if ( $@ ) {
	  print $this->{dbh}->errstr; 
		return undef; 
	}

	my $out = '<ul class="nav nav-tabs">';
  while ( my $row = $sth->fetchrow_hashref ) { 
    $row->{'dlist_name'} = str_encode ($row->{'dlist_name'}); 
	  $out .= '<li><a href="#pearlpbx_direction_edit" data-toggle="modal" 
         onClick="pearlpbx_direction_load_by_id(\''.$row->{'dlist_id'}.'\',
          \''.$row->{'dlist_name'}.'\')">'.
         $row->{'dlist_name'}.'</a></li>';
	}		 
  $out .= "</ul>";
	return $out; 
}

sub getdirectionAsJSON { 
  my ($this, $dlist_id) = @_; 
  my $sql = "select dr_id, dr_prefix, dr_prio from routing.directions where dr_list_item=? order by dr_id"; 
  my $sth = $this->{dbh}->prepare($sql); 
  eval { $sth->execute($dlist_id); }; 
  if ( $@ ) { 
      print $this->{dbh}->errstr; 
      return undef; 
  }
  my @rows;
  while ( my $row = $sth->fetchrow_hashref) { 
    push @rows, $row; 
  } 
  return encode_json(\@rows);
}

sub addprefix { 
  my ($this, $dlist_id, $prefix, $prio) = @_; 

  my $sql = "select dr_id,dr_list_item from routing.directions where dr_prefix=?"; 
  my $sth = $this->{dbh}->prepare ($sql);
  eval { $sth->execute($prefix); };
  if ($@) { 
    return 'ERROR: '.$this->{dbh}->errstr; 
  }

  my $row = $sth->fetchrow_hashref;
  if ($row->{'dr_id'}) {
    if (( $row->{'dr_list_item'} eq $dlist_id ) or ( $row->{'dr_list_item'} == $dlist_id )) { return "ALREADY"; } 
    return "ALREADY_ANOTHER";
  }

  $sql = "insert into routing.directions (dr_list_item,dr_prefix,dr_prio) values (?,?,?)";
  $sth = $this->{dbh}->prepare($sql);
  
  eval { $sth->execute($dlist_id,$prefix, $prio);};
  if ($@) { 
    warn $this->{dbh}->errstr;
    return "ERROR";
  }
  $this->{dbh}->commit;
  return "OK";

}

sub removeprefix { 
  my ($this, $dr_id) = @_; 

  my $sql = "delete from routing.directions where dr_id=?";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($dr_id); };
  if ($@) { 
    return 'ERROR: '.$this->{dbh}->errstr; 
  }
  $this->{dbh}->commit;
  return "OK";
}

sub adddirection { 
  my ($this, $dlist_name) = @_; 

  my $sql = "insert into routing.directions_list (dlist_name) values (?) returning dlist_id"; 
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute ($dlist_name); }; 
  if ( $@ ) { 
    return 'ERROR: '.$this->{dbh}->errstr;
  } 
  my $row = $sth->fetchrow_hashref; 
  unless ( $row ) { 
    return 'ERROR: '.$this->{dbh}->errstr;
  }
  my $dlist_id = $row->{'dlist_id'}; 
  $this->{dbh}->commit;
  return "OK:".$dlist_id;
}

sub setdirection {
  my ($this, $dlist_id, $dlist_name) = @_; 
  my $sql = "update routing.directions_list set dlist_name=? where dlist_id=?"; 
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute ($dlist_name, $dlist_id); }; 
  if ( $@ ) { 
    return 'ERROR: '.$this->{dbh}->errstr;
  }
  $this->{dbh}->commit;
  return "OK:".$dlist_id;
}

sub removedirection { 
  my ($this, $dlist_id) = @_;

  my $sql = "delete from routing.directions where dr_list_item=?"; 
  my $sql2 = "delete from routing.directions_list where dlist_id=?";

  my $sth = $this->{dbh}->prepare($sql); 
  eval { $sth->execute($dlist_id); }; 
  if ( $@ ) {
    return $this->{dbh}->errstr;
  } 
  $sth = $this->{dbh}->prepare($sql2);
  eval { $sth->execute($dlist_id); }; 
  if ( $@ ) {
    return $this->{dbh}->errstr;
  } 
  $this->{dbh}->commit;
  return "OK"; 

}

sub getroutingAsJSON { 
  my ($this, $dlist_id) = @_; 
  my $sql = "select route_id, route_step, route_type, destname, sipname from \ 
    routing.get_route_list_gui() where route_direction_id=? order by route_step,sipname"; 
  my $sth = $this->{dbh}->prepare($sql); 
  eval { $sth->execute($dlist_id); }; 
  if ( $@ ) { 
      print $this->{dbh}->errstr; 
      return undef; 
  }
  my @rows;
  while ( my $row = $sth->fetchrow_hashref) { 
    push @rows, $row; 
  } 
  return encode_json(\@rows);
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
sub removeroute { 
  my ($this, $route_id) = @_;

  my $sql = "delete from routing.route where route_id=?";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($route_id); }; 
  if ($@) {
      return $this->{dbh}->errstr;  
  }
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


