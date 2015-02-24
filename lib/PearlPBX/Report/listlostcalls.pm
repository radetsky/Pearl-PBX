#===============================================================================
#
#         FILE:  listlostcalls.pm
#
#  DESCRIPTION:  Расшифровка списка пропущенных звонков. 
#
#===============================================================================
package PearlPBX::Report::listlostcalls;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON; 

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

=item B<report>

       *  Итоговые данные по количеству пропущенных звонков 
       * по группе. 
       * - История пропущенных звонков с сортировкой по времени 
       * в обратном порядке (самые последние пропущенные звонки 
       * вверху, а старые внизу). 
       * - Время звонка.
       * - Сколько времени ожидал на линии.
       * - Когда после этого дозвонился  
       * - Сколько ожидал.
=cut 

sub report {
    my $this = shift;
	my $params = shift;

    my $sincedatetime = $params->{'sincedatetime'};
    my $tilldatetime  = $params->{'tilldatetime'};
    my $queuename = $params->{'queuename'}; 

    unless ( defined ( $sincedatetime ) ) { 
        print "sincedatetime is not defined.";
        return undef; 
    }
    unless ( defined ( $tilldatetime) ) {
        print "tilldatetime is not defined."; 
        return undef; 
    }
    unless ( defined ( $queuename ) ) { 
        print "queuename is not defined."; 
        return undef; 
    }

    my $sql = "select time,callerid,holdtime from queue_parsed where queue=? 
        and success=0 and time between ? and ? order by time desc"; 

    my $sql_redial = "select time,holdtime from queue_parsed where queue=? 
        and callerid=? and success=1 and time between ? and ? order by time desc limit 1"; 

    my $sql_operator_redial = "select calldate, billsec, src from public.cdr where dst=? 
        and calldate between ? and ? and disposition = 'ANSWER' order by calldate limit 1"; 

    my $sth = $this->{dbh}->prepare($sql);

    eval { $sth->execute( $queuename, $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
	
    my @first_rows; 
    while ( my $hash_ref = $sth->fetchrow_hashref ) {
        push @first_rows,$hash_ref; 
    }

    my $sth_redial  = $this->{dbh}->prepare ($sql_redial); 
    my $sth_outtime = $this->{dbh}->prepare ($sql_operator_redial); 

    my @rows; 
    foreach my $row (@first_rows) { 
        my $lucky = $this->_lucky($callerid, $first_time, $sth_redial, $queuename, $tilldatetime); 
        my $outtime = $this->_outtime($callerid, $first_time, $sth_outtime, $tilldatetime); 

        push @rows, { 
            "datetimelost" => $row->{'time'},
            "msisdn" => $row->{'callerid'},
            "holdtime" => $row->{'holdtime'},
            "lucky" => $lucky->{'time'}, 
            "luckyhold" => $lucky->{'holdtime'},
            "outtime" => $outtime->{'calldate'},
            "source" => $outtime->{'src'},
            "billsec" => $outtime->{'billsec'}
         };
    }

    print encode_json (\@rows); 

}
sub _outtime { 
    my ($this, $callerid, $first_time, $sth, $tilldatetime) = @_; 
    eval { $sth->execute ($callerid, $first_time, $tilldatetime); }; 
    if ($@) { 
        $this->{error} = $this->{dbh}->errstr;
        return undef; 
    }
    my $outtime = $sth->fetchrow_hashref; 
    unless ( defined ( $outtime->{'calldate'}) ) { 
        $outtime->{'calldate'} = ''; 
        $outtime->{'source'} = ''; 
        $outtime->{'billsec'} = ''; 
    }    
    return $outtime; 
}

sub _lucky { 
    my ($this, $callerid, $first_time, $sth_redial, $queuename, $tilldatetime) = @_; 

    eval { $sth_redial->execute ($queuename, $callerid, $first_time, $tilldatetime); }; 
    if ($@) { 
        $this->{error} = $this->{dbh}->errstr;
        return undef; 
    }
    my $lucky = $sth_redial->fetchrow_hashref;
    unless ( defined ( $lucky->{'time'}) ) { 
        $lucky->{'time'} = ''; 
        $lucky->{'holdtime'} = ''; 
    }
    return $lucky; 
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


