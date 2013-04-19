#===============================================================================
#
#         FILE:  IVREdit.pm
#
#  DESCRIPTION:  Класс для редактирования контекстов  
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  16.04.2013 
#===============================================================================

package PearlPBX::Module::IVREdit; 

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Module);
use Data::Dumper; 
use JSON; 
use NetSDS::Util::String;

use version; our $VERSION = "0.01";
our @EXPORT_OK = qw();

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

sub context_list { 
	my ($this, $params) = @_; 

	my $sql = "select distinct context from public.extensions_conf order by context;";
	my $sth = $this->{dbh}->prepare($sql); 
	eval { $sth->execute; };
	if ( $@ ) { 
		print "<font color='red'>".$this->{dbh}->errstr."</font>";
		return undef; 
	}
	print '<ul class="nav nav-tabs">'; 
	while ( my $hashref = $sth->fetchrow_hashref ) { 
		print '<li><a href="#pearlpbx_ivr_edit_context" data-toggle="modal" 
			onClick="pearlpbx_ivr_load_context(\''.$hashref->{'context'}.'\')">'.$hashref->{'context'}.'</a></li>'; 
	}
	print '</ul>';
	return 1; 
}
sub getJSON { 
	my ($this, $params) = @_; 

	my $sql = "select id,context,exten,priority,app,appdata from public.extensions_conf where context=? order by exten,priority"; 
	my $sth = $this->{dbh}->prepare($sql); 
	eval { $sth->execute ($params->{'name'}); };
	if ( $@ ) { 
		print "<font color='red'>".$this->{dbh}->errstr."</font>";
		return undef; 
	}
	my @dialplan; 

	while (my $hashref = $sth->fetchrow_hashref ) { 
		push @dialplan,$hashref; 
	}

	my $jdata = encode_json(\@dialplan); 
	print $jdata; 

	return 1; 
}

sub addpriority { 
	my ($this, $params) = @_; 

	my $sql_check = "select count(*) as cnt from public.extensions_conf where context=? and exten=? and priority=?"; 
	my $sth_check = $this->{dbh}->prepare($sql_check);
	eval { $sth_check->execute( $params->{'context'}, $params->{'exten'}, $params->{'priority'} ); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	my $count = $sth_check->fetchrow_hashref; 
	if ($count->{'cnt'} > 0 ) { 
		my $sql = "update public.extensions_conf set app=?,appdata=? where context=? and exten=? and priority=?"; 
		my $sth = $this->{dbh}->prepare($sql); 
		eval { 
			$sth->execute ( $params->{'app'}, $params->{'appdata'},
				$params->{'context'}, $params->{'exten'}, $params->{'priority'} ); 
		};
		if ( $@ ) { 
			print $this->{dbh}->errstr; 
			return undef;
		}
		$this->{dbh}->commit; 
		print "OK"; 
		return 1; 
	}

	my $sql = "insert into public.extensions_conf ( context, exten, priority, app, appdata ) values (?,?,?,?,?)";
	my $sth = $this->{dbh}->prepare($sql); 
	eval { $sth->execute ( $params->{'context'}, $params->{'exten'},
		$params->{'priority'}, $params->{'app'}, $params->{'appdata'}); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	$this->{dbh}->commit; 
	print "OK"; 
	return 1; 
}

sub delpriority { 
	my ($this, $params) = @_; 

	my $sql = "delete from public.extensions_conf where id=?"; 
	my $sth = $this->{dbh}->prepare($sql); 
	eval { $sth->execute($params->{'id'}); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	$this->{dbh}->commit; 
	print "OK"; 
	return 1; 
}

sub uppriority { 
	my ($this, $params) = @_; 

	my $id = $params->{'id'}; 
	my $sql = "select * from public.extensions_conf where id=?";
	my $sth = $this->{dbh}->prepare($sql);
	eval { $sth->execute($id); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	my $row = $sth->fetchrow_hashref; 
	if ($row->{priority} <= 1) { 
		print "OK"; # Проверили, что эта позиция и так есть наивысшей, вернули, что все ОК.
		return 1; 
	}
	# Смотрим, кто на предыдущей позиции. 
	$sql = "select * from public.extensions_conf where context=? and exten=? and priority=?"; 
	my $sth2 = $this->{dbh}->prepare($sql); 
	my $context = $row->{'context'}; 
	my $exten = $row->{'exten'}; 
	my $priority = $row->{'priority'}; 
	my $prev_priority = $priority - 1; 

	eval { $sth2->execute ( $context, $exten, $prev_priority); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	my $row2 = $sth2->fetchrow_hashref; 
	# Теперь меняем их местами. 
	$sql = "update public.extensions_conf set priority=? where id=?"; 
	my $sth3 = $this->{dbh}->prepare($sql); 
	eval { 
		$sth3->execute($row2->{priority},$row->{'id'}); 
		$sth3->execute($row->{priority},$row2->{'id'}); 
	}; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef;
	}
	$this->{dbh}->commit; 
	print "OK"; 
	return 1; 
}

sub downpriority { 
my ($this, $params) = @_; 

	my $id = $params->{'id'}; 
	my $sql = "select * from public.extensions_conf where id=?";
	my $sth = $this->{dbh}->prepare($sql);
	eval { $sth->execute($id); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	my $row = $sth->fetchrow_hashref; 
	my $msql = "select max(priority) as mprio from public.extensions_conf where context=? and exten=?"; 
	my $msth = $this->{dbh}->prepare($msql); 
	eval { $msth->execute ( $row->{'context'}, $row->{'exten'}); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	my $mrow = $msth->fetchrow_hashref; 

	if ($row->{'priority'} >= $mrow->{'mprio'}) { 
		print "OK"; # Проверили, что эта позиция и так есть наивысшей, вернули, что все ОК.
		return 1; 
	}
	# Смотрим, кто на следующей позиции. 
	$sql = "select * from public.extensions_conf where context=? and exten=? and priority=?"; 
	my $sth2 = $this->{dbh}->prepare($sql); 
	my $context = $row->{'context'}; 
	my $exten = $row->{'exten'}; 
	my $priority = $row->{'priority'}; 
	my $next_priority = $priority + 1; 

	eval { $sth2->execute ( $context, $exten, $next_priority); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef; 
	}
	my $row2 = $sth2->fetchrow_hashref; 
	# Теперь меняем их местами. 
	$sql = "update public.extensions_conf set priority=? where id=?"; 
	my $sth3 = $this->{dbh}->prepare($sql); 
	eval { 
		$sth3->execute($row2->{priority},$row->{'id'}); 
		$sth3->execute($row->{priority},$row2->{'id'}); 
	}; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return undef;
	}
	$this->{dbh}->commit; 
	print "OK"; 
	return 1; 
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


