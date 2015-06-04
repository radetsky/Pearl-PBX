#===============================================================================
#
#         FILE:  Academia.pm
#
#  DESCRIPTION:  Специальный отчет для ООО "МЦ Академия" 
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  16.04.2014 
#===============================================================================

package PearlPBX::Report::Academia;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON; 
use Date::Simple qw/date/; 
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
	my $queue =    $params->{'queue'}; 

    # Общее количество звонков, принятых, пропущенных за день ХХХХ-ХХ-ХХ 
	
	my $sql = { 
		'sum1' => sprintf("select count(*) as sum1 from queue_log where time between '%s' and ('%s'::timestamp + '1 day'::interval) and event='ENTERQUEUE' and queuename='%s';", $date, $date, $queue), 
		'lost' => sprintf("select count(*) as sum_lost from queue_log where time between '%s' and ('%s'::timestamp + '1 day'::interval) and event='ABANDON' and queuename='%s';", $date, $date, $queue), 
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

	my @periods = $this->_periods($date, $queue);
	my $position; 

	foreach my $period ( @periods ) { 
		$sql = { 
			'sum1' => sprintf("select count(*) as sum1 from queue_log where time %s and event='ENTERQUEUE' and queuename='%s'; ",
				$period->{'sql'}, $queue), 
			'lost' => sprintf("select count(*) as sum_lost from queue_log where time %s and event='ABANDON' and queuename='%s'", $period->{'sql'}, $queue), 
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

	$template->process('Academia.html', $template_vars) || die $template->error(); 
		
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
	my $dow = date($date); 
	if ( $dow == 0) { # Воскресенье
		return $this->_sunday_period ($date, $queue);  
	}
	if ( $dow == 6) { # Суббота
		return $this->_saturday_period ($date, $queue); 
	} 

	return _work_period ($date, $queue); 

}

sub _sunday_period { 
	my ( $this, $date, $queue) = @_; 
	my $begin; my $end; 

	return ( { 
			'name' => sprintf("Воскресная смена: %s %s - %s %s ", $date, $begin, $date, $end ), 
			'sql' => sprintf(" between '%s %s' and '%s %s' ", $date, $begin, $date, $end ),
			'graphid' => 'graph_sunday'
			} ); 

}

sub _saturday_period { 
		my ( $this, $date, $queue) = @_; 

		return ( { 
			'name' => sprintf("Субботняя смена: %s 7:30 - %s 20:00 ", $date, $date ), 
			'sql' => sprintf(" between '%s 07:30:00' and '%s 20:00:00' ", $date, $date),
			'graphid' => 'graph_saturday'
		} ); 
}

sub _work_period { 
	my ( $this, $date, $queue) = @_; 

	my $s = { 'support' => { 0 => 
		{ 
			begin => '07:00', 
		  	end => '15:00'
		},
		{
			begin => '15:00', 
			end => '22:00'
		} 
	}}; 

	return ( { 
			'name' => sprintf("Первая смена: %s 7:30 - %s 13:59:59 ", $date, $date ), 
			'sql' =>  sprintf(" between '%s 07:30:00' and '%s 13:59:59' ", $date, $date),
			'graphid' => 'graph_1'
		}, 
		{ 
			'name' => sprintf("Вторая смена: %s 14:00 - %s 20:00:00 ", $date, $date), 
			'sql' => sprintf(" between '%s 14:00:00' and '%s 20:00:00' ", $date, $date),
			'graphid' => 'graph_2'
		} ); 
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


