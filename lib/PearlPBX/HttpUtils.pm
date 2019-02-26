package PearlPBX::HttpUtils;

use warnings;
use strict;

use PearlPBX::Logger;
use PearlPBX::Localization;

use Exporter;
use parent qw(Exporter);
our @EXPORT_OK = qw (http_accept_lang http_response);

sub http_response {
    my $env = shift;
    my $code = shift;
    my $response = shift;

    my $req = Plack::Request->new($env);
    my $res = $req->new_response($code);
    $res->body ($response);
    $res->finalize;
}

sub http_accept_lang {

    my $http_accept_lang_str = shift;
    unless ( defined($http_accept_lang_str) ) {
        Debug("Accept-Language is empty. Return 'en'");
        return 'en';
    }

    my @languages = split( /,\s*/, $http_accept_lang_str );
    unless (@languages) {
        Debug("Accept-Language is empty. Return 'en'");
        return 'en';
    }

    my %accept;
    foreach my $part (@languages) {
        my $q;
        my $pri;

        my ( $lang_name, $prio ) = split( ';', $part );
        unless ( defined($prio) ) {
            $pri = 1; # Если ничего не задано через точку с запятой, то приоритет считается наивысшим = 1
        }
        else {
            # Разбиваем prio через '='
            ( $q, $pri ) = split( '=', $prio );
        }
        my ( $short_code, $region ) = split( '-', $lang_name );
        next if $short_code ne 'en' && !exists( TRANSLATE->{$short_code} );
        if ( !exists( $accept{$short_code} ) || $accept{$short_code} < $pri )
        {
            $accept{$short_code} = $pri;
        }
    }

    foreach my $lang ( sort { $accept{$b} <=> $accept{$a} } keys %accept ) {
        return $lang;
    }

    # Should not happens
    Debug("No supported languages. Return 'en'.");
    return 'en';
}

1;
