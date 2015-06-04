#===============================================================================
#
#         FILE:  Shifts.pm
#
#  DESCRIPTION:  Отчет по сменам (смены задаются в pgsql://cal.shifts)
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  04.06.2015 
#===============================================================================

package PearlPBX::Report::Shifts;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON; 
use Date::Simple; 
use NetSDS::Util::String; 

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

#-----------------------------------------------------------------------
sub report {
    my $this = shift;
	my $params = shift;

	my $date  = $params->{'dateFrom'}; 
	my $queue = $params->{'queue'}; 

    # Общее количество звонков, принятых, пропущенных за день ХХХХ-ХХ-ХХ 
	
	my $sql = { 
		'sum1' => sprintf("select count(*) as sum1 from queue_log where time between '%s' and ('%s'::timestamp + '1 day'::interval) and event='ENTERQUEUE' and queuename='%s';", $date, $date, $queue), 
		'lost' => sprintf("select count(*) as sum_lost from queue_log where time between '%s' and ('%s'::timestamp + '1 day'::interval) and event in ('ABANDON','EXITWITHTIMEOUT') and queuename='%s';", $date, $date, $queue), 
		'connected' => sprintf("select count(*) as sum_connected from queue_log where time between '%s' and ('%s'::timestamp + '1 day'::interval) and event = 'CONNECT' and queuename='%s';", $date, $date, $queue)
		};

    my ($sum1, $sum_lost, $sum_connected) = $this->_fetch_data ($sql); 

	my @aOfa; 
	my @positions; 

	# Информация за весь день 
	push @aOfa , [ str_encode('Всего звонков'), $sum1+0 ]; 
	push @aOfa , [ str_encode('Обработано'), $sum_connected+0 ]; 
	push @aOfa , [ str_encode('Пропущено'), $sum_lost+0 ]; 

	my $wholeday = { 
		'name' => 'Общее количество за день', 
		'graphid' => 'graph1', 
		'sum1' => $sum1, 
		'lost' => $sum_lost,
		'connected' => $sum_connected, 
		'jdata' => encode_json (\@aOfa),
	}; 

	push @positions, $wholeday; 
	
#--------------------------------------------- 
# Информация по сменам   
#--------------------------------------------- 

	my $periods = $this->_periods($date, $queue);
	my $position; 

	foreach my $id ( sort keys %{ $periods } ) { 
		my $period = $periods->{$id}; 

		$sql = { 
			'sum1' => sprintf("select count(*) as sum1 from queue_log where time %s and event='ENTERQUEUE' and queuename='%s'; ", $period->{'sql'}, $queue), 
			'lost' => sprintf("select count(*) as sum_lost from queue_log where time %s and event in ('ABANDON','EXITWITHTIMEOUT') and queuename='%s'", $period->{'sql'}, $queue), 
			'connected' => sprintf(" select count(*) as sum_connected from queue_log where time %s and event = 'CONNECT' and queuename='%s';", $period->{'sql'}, $queue)
		}; 

		($sum1, $sum_lost, $sum_connected) = $this->_fetch_data ($sql); 

		my @aOfa2; 
	
		push @aOfa2 , [ str_encode('Всего звонков'), $sum1+0 ]; 
		push @aOfa2 , [ str_encode('Обработано'), $sum_connected+0 ]; 
		push @aOfa2 , [ str_encode('Пропущено'), $sum_lost+0 ]; 

		$position = { 
			'name' => $period->{'name'}, 
			'graphid' => $period->{'graphid'},
			'sum1' => $sum1, 
			'lost' => $sum_lost,
			'connected' => $sum_connected, 
			'jdata' => encode_json (\@aOfa2)
		};

		push @positions, $position;
	} # end of foreach period 
	my $template = Template->new( { 
		INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
		INTERPOLATE  => 1, 
		} ) || die "$Template::ERROR\n"; 

	my $template_vars = { 
			positions => \@positions, 
	};  

	$template->process('Shifts.html', $template_vars) || die $template->error(); 
		
}



sub _fetch_data { 
	my ($this, $queries) = @_; 

	my $sum1 = $this->_fetch_data2($queries->{'sum1'}, 'sum1'); 
	my $lost = $this->_fetch_data2($queries->{'lost'}, 'sum_lost'); 
	my $connected = $this->_fetch_data2($queries->{'connected'}, 'sum_connected'); 

	return ($sum1, $lost, $connected); 
}

sub _fetch_data2 { 
	my ($this, $sql, $name ) = @_; 

	my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute(); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
	my $hash_ref = $sth->fetchrow_hashref;
	return $hash_ref->{$name}; 
}

sub _periods { 
	my ($this, $date, $queue) = @_; 

	my $sql = {
				'sql_date' => "select id, time_start, time_stop, group_name, name from cal.shifts where group_name=? and ( year=? or year is null) and mon=? and mon_day=? order by id", 
				'sql_weekday' => 	'select id, time_start, time_stop, group_name, name from cal.shifts 
									where group_name=? and weekday=? order by id', 
				'sql_default' => 	'select id, time_start, time_stop, group_name, name from cal.shifts 
									where group_name=? order by id' 
	}; # Набор SQL для получения раписания смен в зависимости от 1)  Даты (дня года), 2)  Дня недели (выделяется обычно суббота и воскресенье или просто по-умолчанию. )

	return $this->_work_period ($date, $queue, $sql); 

}

sub _work_period { 
	my ( $this, $date, $queue, $sql) = @_; 

	my $ds = Date::Simple->new ($date); 
	my $year = $ds->year; 
	my $month = $ds->month; 
	my $day_of_month = $ds->day;
	my $day_of_week = $ds->day_of_week;

	# Получаем расписание по дню в году 
	my $sth = $this->{dbh}->prepare($sql->{'sql_date'}); 
	eval { $sth->execute($queue, $year, $month, $day_of_month); }; 
	if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
	my $shifts = $sth->fetchall_hashref('id');
	if ( keys %{ $shifts } == 0 ) { 
		# Теперь ищем по дням недели 
		$sth = $this->{dbh}->prepare($sql->{'sql_weekday'}); 
		eval { $sth->execute ($queue, $day_of_week); }; 
		if ( $@ ) { 
			$this->{error} = $this->{dbh}->errstr;
     	   	return undef;	
		}
		$shifts = $sth->fetchall_hashref('id');
		if ( keys %{ $shifts } == 0 ) {
			# Теперь ищем по-умолчанию 	
			$sth = $this->{dbh}->prepare($sql->{'sql_default'}); 
			eval { $sth->execute ($queue); }; 
			if ( $@ ) { 
				$this->{error} = $this->{dbh}->errstr;
	     	   	return undef;	
			}
			$shifts = $sth->fetchall_hashref('id');	
		}
	}

	# shifts содержит 
	# { id => {time_start, time_stop, group_name, name }}, id2 => {time_start...}
	foreach my $id ( sort keys %{ $shifts } ) { 
		$shifts->{$id}->{'sql'} = $this->_generate_sql_between (
			$date, 
			$shifts->{$id}->{'time_start'}, 
			$shifts->{$id}->{'time_stop'}
		); 
		$shifts->{$id}->{'graphid'} = $shifts->{$id}->{'group_name'} . '_' . $id; 

	}

	return ( $shifts ); 
}

sub _generate_sql_between { 
	my ($this, $datestr, $start, $stop) = @_;

	my ($hh1, $mm1, $ss1) = split (':', $start); 
	my ($hh2, $mm2, $ss2) = split (':', $stop); 

	if ( $hh2 < $hh1 ) { 
		# Ночная смена, переходим на предыдущую ночь 
		my $yesterday = Date::Simple->new ($datestr) - 1; 
		my $yesterday_str = $yesterday->format("%Y-%m-%d"); 
		return sprintf( "between '%s %s' and '%s %s' ", $yesterday_str, $start, $datestr, $stop); 

	} else {
		return sprintf( "between '%s %s' and '%s %s' ", $datestr, $start, $datestr, $stop ); 
	}

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


