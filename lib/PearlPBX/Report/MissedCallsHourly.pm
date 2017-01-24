#===============================================================================
#
#         FILE:  MissedCallsHourly.pm
#
#  DESCRIPTION:  Returns table of missed calls in group formatted by table: X = days, Y = hours (0-23)
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX, Sirena-Apps.com
#      VERSION:  1.0
#      CREATED:  2017-01-24
#===============================================================================
package PearlPBX::Report::MissedCallsHourly;

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

    my $sinceDateTime = $this->filldatetime ( $params->{dateFrom}, "00:00:00" );
    my $tillDateTime  = $this->filldatetime ( $params->{dateTill}, "23:59:59" );
    unless ( defined ( $params->{queue} ) ) {
        $this->{error} = "Queuename is undefined";
        return undef;
    }

    my $zeros = $this->generate_series ( $sinceDateTime, $tillDateTime );
    # $zeros is arrayref;

    my $c = @{$zeros};
    unless ( $c ) {
        $this->{error} = "Generated interval is empty. Check your interval." ;
        return undef;
    }

    my $sql = "select count(*) as missed from queue_parsed where queue=? and time between ? and ?::timestamp + '1 hour'::interval and success=0";
    my $sth = $this->{dbh}->prepare($sql);
    my $report;
    my $dayz;
    foreach my $element ( @$zeros ) {
        my $hour = $element->[0];
        $report->{$hour} = 0;
        my ($day, $time) = split(' ', $hour);
        if ( exists ( $dayz->{$day} ) ) {
            $dayz->{$day} += 1;
        } else {
            $dayz->{$day} = 1;
        }
        eval {
            $sth->execute($params->{queue}, $hour, $hour);
        };
        if ($@) {
            warn $@;
            die;
        }
        my @result = $sth->fetchrow_array;
        $report->{$hour} += $result[0] // 0; # report->{hour} = report->{hour} + X // 0; Value must be Int;
    }
    my $matrix = $this->matrixOfDaysAndHours($report);
    my $template = Template->new ( {
        INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
        INTERPOLATE  => 1,
    } ) || die "$Template::ERROR";

    my @d = sort keys %{ $dayz };
    my $tmpl_vars = {
        matrix => $matrix,
        dayz   => \@d,
    };

    $template->process('MissedCallsHourly.html', $tmpl_vars) || die $template->error();

}

sub matrixOfDaysAndHours {
    my ($this, $report) = @_;
    my $matrix;
    foreach my $hour ( keys %{ $report } ) {
        my ($day, $time) = split(' ', $hour);
        $matrix->{$day}->{$time} = $report->{$hour};
    }
    return $matrix;
}

sub generate_series {
    my ( $this, $since, $till ) = @_;

    my $sql = sprintf("select generate_series ( '%s'::timestamp, '%s'::timestamp, '1 hour')",
            $since, $till );
    my $sth = $this->{dbh}->prepare($sql);
    eval {
        $sth->execute();
    };

    if ( $@ ) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    return $sth->fetchall_arrayref;
}


1;

