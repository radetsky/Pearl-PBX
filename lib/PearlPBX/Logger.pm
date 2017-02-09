package PearlPBX::Logger;

use warnings;
use strict;
use utf8;
use open qw(:std :utf8);

use feature 'state';

use Sys::Syslog qw(:standard :macros);
use constant {
    FACILITY => LOG_USER,
    PROGNAME => "PearlPBX",
    LOGOPTS  => 'pid',
};

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw(
    Log
    Logf
    Debug
    Debugf
    Info
    Infof
    Err
    Errf
    _subst_errmsg
    _log_timestamp
);

use Carp;
use Time::HiRes qw(time);
use POSIX qw(strftime);
use Data::Dumper;
use Scalar::Util qw(reftype);
use Clone qw(clone);

my %PRIO = map { $_ => 1 } qw(debug info err);

use constant LOG_STDERR => $ENV{LOG_STDERR} ? 1 : 0;

$Data::Dumper::Terse = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Useqq = 1;
{
    no warnings 'redefine';
    sub Data::Dumper::qquote {
        my $s = shift;
        my $utf8 = utf8::is_utf8($s) ? 'utf8:' : '';
        utf8::decode($s) unless $utf8;
        return "$utf8'$s'";
    }
}
my $LOG_OPENED;

sub _Logf
{
    my $prio = shift;
    my $format = shift;
    defined($format) or confess "Log format undefined";

    if (!$LOG_OPENED) {
        closelog();
        openlog(PROGNAME, LOGOPTS, FACILITY);
        $LOG_OPENED = 1;
    }
    syslog($prio, "[$prio]".$format, @_);
}

sub Logf
{
    my $prio = shift;

    defined($prio) && exists $PRIO{$prio}
        or confess "Bad or missing log priority";
    my $format = shift;
    my @args = @_;
    defined($format) or confess "Log format undefined";
    utf8::decode($format) unless utf8::is_utf8($format);
    foreach (@args) {
        if (!defined $_) {
            carp "Undefined Logf parameter";
            $_ = '[undef]';
        } elsif (ref $_) {
            $_ = Dumper($_);
        } else {
            utf8::decode($_) unless utf8::is_utf8($_);
        }
    }
    if (LOG_STDERR) {
        $format = _subst_errmsg($format);
        printf STDERR ("%s $format\n", _log_timestamp(), @args);
    } else {

        my $i = 0;
        my @mess;

        do {
            @mess = caller($i++);
        } while __PACKAGE__ eq $mess[0];
        _Logf ($prio, '%s line %u: ' . $format, $mess[1], $mess[2], @args);
    }
}

# Subst "%m" with $! in format
sub _subst_errmsg
{
    my $format = shift;

    my $strerr = $!;
    $strerr =~ s/%/%%/g;
    $format =~ s/(?<!%)((?:%%)*)%m/$1$strerr/g;
    return $format;
}

sub _log_timestamp
{
    my $t = shift // time();
    return strftime("%F %T", localtime($t)) . sprintf('.%03d', ($t-int($t)) * 1000);
}

sub Log
{
    my ($prio, $line) = @_;

    defined($line) or confess "Log line undefined";
    @_ == 2 or confess "Extra params for Log";
    Logf($prio, '%s', $line);
}

sub Debug
{
    Log('debug', @_);
}

sub Debugf
{
    # TODO: log only in development mode
    Logf('debug', @_);
}

sub Info
{
    Log('info', @_);
}

sub Infof
{
    Logf('info', @_);
}

sub Err
{
    Log('err', @_);
}

sub Errf
{
    Logf('err', @_);
}


1;

