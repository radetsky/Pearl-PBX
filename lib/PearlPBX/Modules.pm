package PearlPBX::Modules;

# 2017-07-20.
# I rewrite Pearl.pm to this package to use it with Plack.
# I'm going PearlPBX to Docker.
# I try to build project again

use warnings;
use strict;

use Exporter;
use parent qw(Exporter);

our @EXPORT = qw (
    modules_names
    modules_bodies
);

use constant MODULES_DIR => '/usr/share/pearlpbx/modules/';

sub modules_names {
    my $rtype = shift;

    return _read1stlines ( _verify_path ($rtype ) );
}

sub modules_bodies {
    my $rtype = shift;

    return _readwholebodies ( _verify_path ( $rtype ) );
}

sub _verify_path {
    my $rtype = shift;
    my $dirname = MODULES_DIR;

    unless ( defined ( $rtype ) ) {
        return $dirname;
    }
    if ($rtype =~ /^ivr$/) {
        $dirname .= $rtype;
    } elsif ($rtype =~ /^katyusha$/ ) {
        $dirname .= $rtype;
    } elsif ($rtype =~ /^konference$/ ) {
        $dirname .= $rtype;
    } elsif ($rtype =~ /^backup$/ ) {
        $dirname .= $rtype;
    }

    return $dirname;
}



=item B<read1stlines(directory)

 Возвращает список уловных обозначений и наименований файлов.
 Пример: ((001-alltraffic,Весь траффик),(007-internalcalls,Внутренние звонки))
 Условные обозначения - это имена файлов без расширения,
 Наименование отчета - первая строка из файла html внутри комментария.

=cut

sub _read1stlines {
    my $dirname = shift;
    my @result;

    opendir my ($dh), $dirname or return undef;
    my @files = readdir $dh;
    closedir $dh;
    foreach my $filename (sort @files) {
        if ($filename =~ /\.html$/) {
            # try to read first line
            next unless ( open ( my $fh, $dirname.'/'.$filename ) );
            my $firstline = <$fh>;
            close $fh;
            # cut off comment chars
            $firstline =~ s/<!--//g;
            $firstline =~ s/-->//g;
            $filename =~ s/\.html$//g;
            push @result, [ $filename, $firstline ];
        }
    }
    return @result;
}

sub _readwholebodies {
    my $dirname = shift;
    my $result  = '';

    opendir my ($dh), $dirname or return undef;
    my @files = readdir $dh;
    closedir $dh;

    foreach my $filename (sort @files) {
        if ($filename =~ /\.html$/) {
            next unless ( open ( my $fh, $dirname.'/'.$filename ) );
            my @body = <$fh>;
            close $fh;
            $filename =~ s/\.html$//g;
            $result .= '<div id="'.$filename.'">';
            foreach my $line (@body) {
                $result .= $line;
            }
            $result .= '</div>';
        }
    }
    return $result;
}
