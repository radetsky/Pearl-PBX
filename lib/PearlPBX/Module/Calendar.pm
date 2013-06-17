#===============================================================================
#
#         FILE:  Calendar.pm
#
#  DESCRIPTION:  Класс для управления календарём рабочих и выходных дней. 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  30.03.2013 12:19:09 EET
#===============================================================================
=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Module::Calendar; 

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Module);
use Data::Dumper; 
use JSON; 
use NetSDS::Util::String;


use version; our $VERSION = "0.01";
our @EXPORT_OK = qw();

my $months = { 1 => 'Января', 2 => 'Февраля', 3 => 'Марта', 4 => 'Апреля', 5 => 'Мая', 6 => 'Июня',
	7 => 'Июля', 8 => 'Августа', 9 => 'Сентября', 10 => 'Октября', 11 => 'Ноября', 12 => 'Декабря'};

my $wdays = { 1 => 'Понедельник', 2 => 'Вторник', 3 => 'Среда', 4 => 'Черверг', 5 => 'Пятница',
	6 => 'Суббота', 0 => 'Воскресенье'}; 


#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}


sub getJSON {
	my $this = shift; 

	my $sql = "select * from cal.timesheet order by prio,id"; 
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute; }; 
    if ( $@ ) {
        print $this->{dbh}->errstr;
        return undef;
    }

    my @timesheet; 

    while (my $hashref = $sth->fetchrow_hashref ) {
    	unless ( defined ($hashref->{'weekday'} ) ) { 
    		$hashref->{'weekday'} = str_encode(' '); 
    	} else { 
    		$hashref->{'weekday'} = str_encode($wdays->{$hashref->{'weekday'}}); 
    	} 

    	unless ( defined ($hashref->{'year'} ) ) { 
    		$hashref->{'year'} = str_encode(' '); 
    	}
    	unless ( defined ($hashref->{'group_name'} ) ) { 
    		$hashref->{'group_name'} = str_encode(' ');
    	}
    	unless ( defined ($hashref->{'mon_day'})) { 
    		$hashref->{'mon_day'} = str_encode(' ');
    	}
    	unless ( defined ($hashref->{'mon'})) { 
    		$hashref->{'mon'} = str_encode(' ');
    	} else { 
    		$hashref->{'mon'} = str_encode($months->{$hashref->{'mon'}});
    	}
    	unless ( $hashref->{'is_work'} ) { 
    		$hashref->{'is_work'} = str_encode("<font color='red'>Выходной</font>");
    	} else { 
    		$hashref->{'is_work'} = str_encode("<font color='black'>Рабочий</font>");
    	}

    	push @timesheet,$hashref; 
    }
    
    my $jdata  = encode_json(\@timesheet); 

    print $jdata; 
    return 1; 

}

sub add { 
	my ($this,$params) = @_; 

	my $sql = "insert into cal.timesheet (weekday,mon_day,mon,year,time_start,time_stop,group_name,is_work,prio) 
		values (?,?,?,?,?,?,?,?,?); "; 

	my $sth = $this->{dbh}->prepare($sql); 

	my $wday = str_trim($params->{'wday'});
	undef $wday if $wday =~ /^0/;
	$wday = 0 if $wday == 7; 

	my $mday = str_trim($params->{'mday'}); 
	undef $mday if $mday =~ /^0/;  

	my $mon = str_trim($params->{'mon'});
	undef $mon if $mon =~ /^0/; 

	my $year = str_trim($params->{'year'}); 
	undef $year if $year eq ''; 

	my $time_start = str_trim($params->{'time_start'}); 
	my $time_stop = str_trim($params->{'time_stop'}); 
	my $group_name = str_trim($params->{'group_name'}); 
	my $is_work = str_trim($params->{'is_work'}); 
	my $prio = str_trim($params->{'prio'}); 
	if ($prio eq '') { $prio = 900; } 

	eval { $sth->execute ($wday,$mday,$mon,$year,$time_start,$time_stop,$group_name,$is_work,$prio); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return;
	}
	$this->{dbh}->commit; 
	print "OK"; 
	return;

}

sub del { 
	my ($this, $params) = @_; 

	my $sql = "delete from cal.timesheet where id=?";
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute($params->{'id'}); };
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return;
	}
	
	$this->{dbh}->commit; 
	print "OK"; 
	return;

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


