package PearlPBX::ScalarUtils;

=head1 SYNOPSIS

    use Buratino::ScalarUtils qw/trim/;
    my $trimmed = trim($user_input);
    my @trimmed_list = map trim, (" left_spaces", " around_spaces   ");


=head1 DESCRIPTION

module with some useful scalar functions

=head1 FUNCTIONS

=over 4

=item trim

trims heading and trailing spaces from string

=back

=cut

use strict;
use warnings;

our @EXPORT_OK = qw(
    trim
    trim_hashref
    remove_stackdump
    utf8_encode_hash
    utf8_decode_hash
    utf8_downgrade_hash
);
use Exporter 'import';

use Carp;
use Clone qw(clone);
use Scalar::Util qw(reftype);

sub trim (;$) {
    if ( @_ ) {
        my $str = $_[0];
        if (defined $str) {
            $str =~ s/^\s+//;
            $str =~ s/\s+$//;
        } else {
            carp 'Undefined trim parameter';
        }
        return $str;
    } elsif (defined $_) {
        s/^\s+//;
        s/\s+$//;
        return $_
    } else {
        carp 'trim with no args nor $_';
        return undef;
    }
}

sub trim_hashref
{
    my $params = shift;

    my ($exclude) = @_;
    $exclude = [ @_ ] unless ref $exclude;

    foreach my $t (keys %$params) {
        $params->{$t} //= '';
        $params->{$t} = trim($params->{$t}) unless grep {$t =~ /$_/} @$exclude;
    }
    return $params;
}

sub remove_stackdump($) {
    my $str = shift;
    $str =~ s/(?:\n| in call to| at \S+ line).*//s;
    return $str;
}

sub utf8_encode_hash {
    my ($param) = @_;

    if (ref $param eq '') {
        utf8::encode($_[0]) if utf8::is_utf8($param);
    } elsif (ref $param eq 'HASH') {
        foreach my $key (keys %$param) {
            utf8_encode_hash($param->{$key});
        }
    } elsif (ref $param eq 'ARRAY') {
        foreach my $key (@$param) {
            utf8_encode_hash($key);
        }
    }
}

sub utf8_decode_hash {
    my ($param) = @_;

    if (ref $param eq '') {
        utf8::decode($_[0]) unless utf8::is_utf8($param);
    } elsif (ref $param eq 'HASH') {
        foreach my $key (keys %$param) {
            utf8_decode_hash($param->{$key});
        }
    } elsif (ref $param eq 'ARRAY') {
        foreach my $key (@$param) {
            utf8_decode_hash($key);
        }
    }
}

sub utf8_downgrade_hash {
    my ($param) = @_;

    if (ref $param eq '') {
        utf8::downgrade($_[0]) if utf8::is_utf8($param);
    } elsif (ref $param eq 'HASH') {
        foreach my $key (keys %$param) {
            utf8_downgrade_hash($param->{$key});
        }
    } elsif (ref $param eq 'ARRAY') {
        foreach my $key (@$param) {
            utf8_downgrade_hash($key);
        }
    }
}

1;
