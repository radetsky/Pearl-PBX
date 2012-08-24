#===============================================================================
#
#         FILE:  Queues.pm
#
#  DESCRIPTION:  PearlPBX Queues management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  23.06.12
#      REVISION: 001 
#===============================================================================
=head1 NAME

PearlPBX::Queues

=head1 SYNOPSIS

	use PearlPBX::Queues;

=cut

package PearlPBX::Queues;

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
sub list_as_li { 
	my $this = shift;
	my $sql = "select name from public.queues order by name";

	return $this->_list($sql);
}


sub _list { 
	my ($this, $sql) = @_; 

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
	   $out .= '<li><a href="#pearlpbx_queues_edit" data-toggle="modal" 
         onClick="pearlpbx_queues_load_by_name(\''.$row->{'name'}.'\')">'.$row->{'name'}.'</a></li>';
	}		 
  $out .= "</ul>";
	return $out; 
}

sub getqueue { 
  my ($this, $qname) = @_; 

  my $sql = "select * from public.queues where name=?";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute ($qname); }; 
  if ($@) { 
    print $this->{dbh}->errstr; 
    return undef; 
  }
  my $row = $sth->fetchrow_hashref;
  return encode_json($row);

}

sub setqueue { 
  my ($this, $oldname, $name, $strategy, $timeout, $maxlen) = @_; 

  #  Сохраняем параметры группы

  my $sql = "update public.queues set name=?, strategy=?, timeout=?, maxlen=? where name=?";  
  my $sth  = $this->{dbh}->prepare($sql);
  eval { 
    $sth->execute ($name, $strategy, $timeout, $maxlen, $oldname); 
  };
  if ($@) { 
    warn $this->{dbh}->errstr;
    return 'ERROR'; 
  }

  # Если у группы новое имя, то стоит и членам группы поменять название группы 
  if ( $oldname ne $name ) {
    $sql = "update public.queue_members set queue_name=? where queue_name=?"; 
    $sth  = $this->{dbh}->prepare($sql);
    eval { 
      $sth->execute ($name, $oldname); 
    };
    if ($@) { 
      warn $this->{dbh}->errstr;
      return 'ERROR'; 
    }
  }

  $this->{dbh}->commit;
  return "OK";

}

sub addqueue { 
  my ($this, $name, $strategy, $timeout, $maxlen) = @_; 

  my $sql = "insert into public.queues (name, strategy,timeout,maxlen ) values ( ?, ? ,? ,?);"; 
  my $sth  = $this->{dbh}->prepare($sql);
  eval { 
    $sth->execute ($name, $strategy, $timeout, $maxlen ); 
  };
  if ($@) { 
    warn $this->{dbh}->errstr;
    return 'ERROR'; 
  }
  $this->{dbh}->commit;
  return "OK";

}

sub listmembersAsJSON { 
  my ($this, $qname) = @_;

  my $sql = "select membername,interface from queue_members where queue_name = ? order by membername"; 
  my $sth = $this->{dbh}->prepare($sql);
  eval { 
    $sth->execute ($qname);
  };
  if ($@) { 
    warn $this->{dbh}->errstr;
    return 'ERROR';
  }

  my @rows; 
  while (my $row = $sth->fetchrow_hashref) {
    push @rows,$row;
  }

  return encode_json(\@rows);

}

sub addmember { 
  my ($this, $qname, $member) = @_; 

  # Check for existing operator. 
  my $sql = "select membername,interface from public.queue_members where queue_name=? and membername=?";
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($qname,$member);};
  if ($@) { 
    warn $this->{dbh}->errstr;
    return "ERROR";
  }
  my $row = $sth->fetchrow_hashref;
  if ($row->{'membername'}) { 
    return "ALREADY";
  }
  $sql = "insert into public.queue_members (membername,queue_name,interface) values (?,?,?);";
  $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($member,$qname,'SIP/'.$member);};
  if ($@) { 
    warn $this->{dbh}->errstr;
    return "ERROR";
  }
  $this->{dbh}->commit;
  return "OK";

}

sub removemember { 
  my ($this, $qname, $member) = @_; 

  my $sql = "delete from public.queue_members where queue_name=? and membername=?"; 
  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute($qname,$member);};
  if ($@) { 
    warn $this->{dbh}->errstr;
    return "ERROR";
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


