#===============================================================================
#         FILE:  CallsForTheGroup.pm
#  DESCRIPTION:  Returns sum of total and missed calls for the group for period
#       AUTHOR:  Alex Radetsky (Rad), <rad@fullstack.center>
#      COMPANY:  PearlPBX
#      CREATED:  2020-03-08 ( Dzien Kobiet )
#===============================================================================
package PearlPBX::Report::CallsForTheGroup;
use warnings;
use strict;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON;

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

sub new {
    my ($class, $conf) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

sub _connected {
    my $this = shift;
    my $qname = shift;
    my $since = shift;
    my $till = shift;

    # Принятых без учета адресной книги.
    my $sql_connected = "select count(queue) as s from public.queue_parsed where queue=?
    and time between ? and ? and success=1 and callerid not in (select msisdn from ivr.addressbook)";

    my $sth_connected = $this->{dbh}->prepare($sql_connected);
    eval { $sth_connected->execute( $qname, $since, $till); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $fetch_connected = $sth_connected->fetchrow_hashref;
    my $connected = $fetch_connected->{'s'}+0;

    return $connected;
}

sub _missed {
    my $this = shift;
    my $qname = shift;
    my $since = shift;
    my $till = shift;

    # Пропущенных без учета адресной книги.
    my $sql_missed = "select count(queue) as s from public.queue_parsed where queue=?
    and time between ? and ? and success=0 and callerid not in (select msisdn from ivr.addressbook)";
    my $sth_missed = $this->{dbh}->prepare($sql_missed);
    eval { $sth_missed->execute( $qname, $since, $till); };
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

  # Подробный список пропущенных
  my $sql = "select time,callerid,holdtime from queue_parsed where queue=?
      and success=0 and time between ? and ? order by time desc";

  # Список дозвонившихся после пропущенного
  my $sql_redial = "select time,holdtime from queue_parsed where queue=?
      and callerid=? and success=1 and time between ? and ? order by time desc limit 1";

  # Список обработанных операторами
  my $sql_operator_redial = "select calldate, billsec, src from public.cdr where dst=?
      and calldate between ? and ? and disposition = 'ANSWERED' order by calldate limit 1";

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

  my $lucky = 0;
  my $done  = 0;
  foreach my $row (@first_rows) {
    my $callerid = $row->{'callerid'};
    my $first_time = $row->{'time'};
    unless ( defined ( $this->_lucky($callerid, $first_time, $sth_redial, $queuename, $tilldatetime) ) ) {
      unless ( defined ( $this->_outtime($callerid, $first_time, $sth_outtime, $tilldatetime) ) ) {
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
    my ($this, $callerid, $first_time, $sth, $tilldatetime) = @_;
    eval { $sth->execute ($callerid, $first_time, $tilldatetime); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $outtime = $sth->fetchrow_hashref;
    unless ( defined ( $outtime->{'calldate'}) ) { return undef; }
    return 1;
}

sub _lucky {
    my ($this, $callerid, $first_time, $sth_redial, $queuename, $tilldatetime) = @_;

    eval { $sth_redial->execute ($queuename, $callerid, $first_time, $tilldatetime); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $lucky = $sth_redial->fetchrow_hashref;
    unless ( defined ( $lucky->{'time'}) ) { return undef; }
    return 1;
}


sub report {
    my ($this, $params) = @_;

    my $sincedatetime = $this->filldatetime ( $params->{dateFrom}, $params->{'timeFrom'} );
    my $tilldatetime  = $this->filldatetime ( $params->{dateTill}, $params->{'timeTo'} );

    unless ( defined ( $params->{queue} ) ) {
        $this->{error} = "Queuename is undefined";
        warn "Queue is undefined";
        return undef;
    }
    # Всего в отчете надо получить такую информацию.
    # Кол-во принятых, кол-во пропущенных, всего, процент пропущенных.

    my $connected = $this->_connected($params->{queue}, $sincedatetime, $tilldatetime);
    return undef unless ( defined ( $connected ) );
    my $missed = $this->_missed($params->{queue}, $sincedatetime, $tilldatetime);
    return undef unless ( defined ( $missed ) );
    my ($lucky, $done ) =  $this->_get_lucky_done ($params->{queue}, $sincedatetime, $tilldatetime);
    my $lost = $missed - $lucky - $done;

    # Если на одного и того же пользователя был и повторный дозвон и обратный callback, 
    # То будут минусы. 
    $lost = 0 if $lost < 0; 

    # Всего.
    my $total = $connected + $missed;

    # Процент пропущенных
    my $p_lost = ($lost * 100) / $total;

    my $template = Template->new ( {
        INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
        INTERPOLATE  => 1,
    } ) || die "$Template::ERROR";

    my $tmpl_vars = {
        connected => $connected,
        lost => $lost,
        total => $total,
        p_lost => sprintf("%.2f", $p_lost),
    };

    $template->process('CallsForTheGroup.html', $tmpl_vars) || die $template->error();

}

1;

