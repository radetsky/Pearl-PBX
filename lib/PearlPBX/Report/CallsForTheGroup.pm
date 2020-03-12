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

sub report {
    my ($this, $params) = @_;

    my $sincedatetime = $this->filldatetime ( $params->{dateFrom}, "00:00:00" );
    my $tilldatetime  = $this->filldatetime ( $params->{dateTill}, "23:59:59" );
    unless ( defined ( $params->{queue} ) ) {
        $this->{error} = "Queuename is undefined";
        warn "Queue is undefined"; 
        return undef;
    }
    # Всего в отчете надо получить такую информацию.
    # Кол-во принятых, кол-во пропущенных, всего, процент пропущенных.

    # Принятых.
    my $sql_connected = "select count(queuename) as s from queue_log where event='CONNECT' and queuename=? and time between ? and ?";
    my $sth_connected = $this->{dbh}->prepare($sql_connected);
    eval { $sth_connected->execute( $params->{queue}, $sincedatetime, $tilldatetime); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $fetch_connected = $sth_connected->fetchrow_hashref;
    my $connected = $fetch_connected->{'s'}+0;

    # Пропущенных
    my $sql_lost = "select count(queue) as s from public.queue_parsed where queue = ? and time between ? and ? and success=0";
    my $sth_lost = $this->{dbh}->prepare($sql_lost);
    eval { $sth_lost->execute( $params->{queue}, $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
    my $fetch_lost = $sth_lost->fetchrow_hashref;
    my $lost = $fetch_lost->{'s'}+0;

    # Всего.
    my $total = $lost + $connected;

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

