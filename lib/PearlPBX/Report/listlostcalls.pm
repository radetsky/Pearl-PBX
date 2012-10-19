#===============================================================================
#
#         FILE:  LostInGroups.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 05:30:27 EEST
#===============================================================================

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

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

    my $sth_redial = $this->{dbh}->prepare ($sql_redial); 
    my @rows; 
    foreach my $row (@first_rows) { 
        my $callerid = $row->{'callerid'}; 
        eval { $sth_redial->execute ($queuename, $callerid, $sincedatetime, $tilldatetime);}; 
        if ($@) { 
            $this->{error} = $this->{dbh}->errstr;
            return undef; 
        }
        my $lucky = $sth_redial->fetchrow_hashref;
        unless ( defined ( $lucky->{'time'}) ) { 
            $lucky->{'time'} = ''; 
            $lucky->{'holdtime'} = ''; 
        }
        push @rows, { 
            "datetimelost" => $row->{'time'},
            "msisdn" => $row->{'callerid'},
            "holdtime" => $row->{'holdtime'},
            "lucky" => $lucky->{'time'}, 
            "luckyhold" => $lucky->{'holdtime'}
         };
    }

    print encode_json (\@rows); 

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


