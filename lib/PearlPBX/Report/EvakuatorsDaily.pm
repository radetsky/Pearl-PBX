#===============================================================================
#         FILE:  EvakuatorsDaily.pm
#  DESCRIPTION:  Returns count of accepted and missed incoming calls for every hour in selected day
#       AUTHOR:  Alex Radetsky (Rad), <rad@fullstack.center>
#      COMPANY:  PearlPBX
#      CREATED:  2020-04-06 ( Quarantine-Quarantine! Drink your whiskey like vaccine )
#===============================================================================
package PearlPBX::Report::EvakuatorsDaily;
use warnings;
use strict;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON;

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

my @HOURS = (
    ['00:00:00','00:59:59'],
    ['01:00:00','01:59:59'],
    ['02:00:00','02:59:59'],
    ['03:00:00','03:59:59'],
    ['04:00:00','04:59:59'],
    ['05:00:00','05:59:59'],
    ['06:00:00','06:59:59'],
    ['07:00:00','07:59:59'],
    ['08:00:00','08:59:59'],
    ['09:00:00','09:59:59'],
    ['10:00:00','10:59:59'],
    ['11:00:00','11:59:59'],
    ['12:00:00','12:59:59'],
    ['13:00:00','13:59:59'],
    ['14:00:00','14:59:59'],
    ['15:00:00','15:59:59'],
    ['16:00:00','16:59:59'],
    ['17:00:00','17:59:59'],
    ['18:00:00','18:59:59'],
    ['19:00:00','19:59:59'],
    ['20:00:00','20:59:59'],
    ['21:00:00','21:59:59'],
    ['22:00:00','22:59:59'],
    ['23:00:00','23:59:59'],
);

# foreach my $h (@HOURS) {
# print $h->[0] . " -> " . $h->[1] . "\n";
# }

sub new {
    my ($class, $conf) = @_;
    my $this = $class->SUPER::new($conf);

    $this->{'connected_with_queue'} = $this->{dbh}->prepare("select count(queue) as s from public.queue_parsed where queue=?
                           and time between ? and ? and success=1 and callerid not in (select msisdn from ivr.addressbook)");

    $this->{'connected_total'} = $this->{dbh}->prepare("select count(queue) as s from public.queue_parsed where
                           time between ? and ? and success=1 and callerid not in (select msisdn from ivr.addressbook)");

    $this->{'missed_with_queue'} = $this->{dbh}->prepare("select count(queue) as s from public.queue_parsed where queue=?
                           and time between ? and ? and success=0 and callerid not in (select msisdn from ivr.addressbook)");

    $this->{'missed_total'} = $this->{dbh}->prepare("select count(queue) as s from public.queue_parsed where
                           time between ? and ? and success=0 and callerid not in (select msisdn from ivr.addressbook)");

    # Подробный список пропущенных
    $this->{'missed_list'} = $this->{dbh}->prepare("select time,callerid,holdtime from queue_parsed where queue=?
                           and success=0 and time between ? and ? order by time desc");

    # Список дозвонившихся после пропущенного
    $this->{'missed_lucky'} = $this->{dbh}->prepare("select time,holdtime from queue_parsed where queue=?
                          and callerid=? and success=1 and time between ? and ? order by time desc limit 1");

    # Список обработанных операторами
    $this->{'missed_done'} = $this->{dbh}->prepare("select calldate, billsec, src from public.cdr where dst=?
                          and calldate between ? and ? and disposition = 'ANSWERED' order by calldate limit 1");

    bless $this;
    return $this;
}

sub _connected {
    my $this = shift;
    my $qname = shift;
    my $since = shift;
    my $till = shift;

    my $sth_connected;
    if ($qname ne 'total') {
        $sth_connected = $this->{'connected_with_queue'}; # prepared statement
        eval { $sth_connected->execute( $qname, $since, $till); };

    } else {
        $sth_connected = $this->{'connected_total'}; # prepared statement
        eval { $sth_connected->execute( $since, $till); };
    }
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    my $fetch_connected = $sth_connected->fetchrow_hashref;
    my $connected = $fetch_connected->{'s'}+0;

    return $connected;
}

sub _missed {
    my $this  = shift;
    my $qname = shift;
    my $since = shift;
    my $till  = shift;

    my $sth_missed;

    if ($qname ne 'total') {
        $sth_missed = $this->{'missed_with_queue'};
        eval { $sth_missed->execute( $qname, $since, $till); };
    } else {
        $sth_missed = $this->{'missed_total'};
        eval { $sth_missed->execute( $since, $till); };
    }
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $fetch_missed = $sth_missed->fetchrow_hashref;
    my $missed = $fetch_missed->{'s'}+0;
    return $missed;
}

sub _get_lucky_done {
  my ($this, $queuename, $sincedatetime, $tilldatetime) = @_;

  eval { $this->{'missed_list'}->execute( $queuename, $sincedatetime, $tilldatetime ); };
  if ($@) {
      $this->{error} = $this->{dbh}->errstr;
      return undef;
  }

  my @first_rows;
  while ( my $hash_ref = $this->{'missed_list'}->fetchrow_hashref ) {
      push @first_rows,$hash_ref;
  }

  my $till = $this->{'date'} . ' 23:59:59'; # Until the end of the day
  my $lucky = 0;
  my $done  = 0;

  foreach my $row (@first_rows) {
    my $callerid   = $row->{'callerid'};
    my $first_time = $row->{'time'};
    unless ( defined ( $this->_lucky($callerid, $first_time, $queuename, $till) ) ) {
      unless ( defined ( $this->_outtime($callerid, $first_time, $till) ) ) {
        next;
      } else {
        $done++;
      }
    } else {
      $lucky++;
    }
  }

  return ($lucky, $done);
}

sub _outtime {
    my ($this, $callerid, $first_time, $till) = @_;
    eval { $this->{'missed_done'}->execute ($callerid, $first_time, $till); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $outtime = $this->{'missed_done'}->fetchrow_hashref;
    unless ( defined ( $outtime->{'calldate'}) ) { return undef; }
    return 1;
}

sub _lucky {
    my ($this, $callerid, $first_time, $queuename, $tilldatetime) = @_;

    eval { $this->{'missed_lucky'}->execute ($queuename, $callerid, $first_time, $tilldatetime); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $lucky = $this->{'missed_lucky'}->fetchrow_hashref;
    unless ( defined ( $lucky->{'time'}) ) { return undef; }
    return 1;
}

sub report {
    my ($this, $params) = @_;
    my $since = $params->{dateFrom};
    my $queue = $params->{queue};

    # Save to use later in class
    $this->{'date'} = $since;
    my @result;
    my @graph;

    my $current_hour = 0; # 0 - 23
    foreach my $h (@HOURS) {
        my $start = $h->[0];
        my $stop  = $h->[1];

        my $sincedatetime = $since . " " . $start;
        my $tilldatetime  = $since . " " . $stop;

        my $connected = $this->_connected($queue, $sincedatetime, $tilldatetime);
        return undef unless ( defined ( $connected ) );
        my $missed =    $this->_missed   ($queue, $sincedatetime, $tilldatetime);
        return undef unless ( defined ( $missed ) );
        my ($lucky, $done ) = $this->_get_lucky_done ($queue, $sincedatetime, $tilldatetime);
        my $lost = $missed - $lucky - $done;
        $lost = 0 if $lost < 0;
        my $total = $connected + $missed;
        my $p_lost = ($lost * 100) / $total;
        my $result_row = {
            hour => $current_hour,
            sincedatetime => $sincedatetime,
            tilldatetime => $tilldatetime,
            connected => $connected,
            lost => $lost,
            total => $total,
            p_lost => $p_lost
        };
        push @result, $result_row;
        push @graph, {
            hour => $current_hour,
            connected => $connected,
            lost => $lost,
        };

    }

    my $jdata = encode_json(\@graph);

    my $template = Template->new ( {
        INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
        INTERPOLATE  => 1,
    } ) || die "$Template::ERROR";

    my $tmpl_vars = {
        jdata => $jdata,
        rawdata => \@result,
    };

    $template->process('EvakuatorsDaily.html', $tmpl_vars) || die $template->error();

}


