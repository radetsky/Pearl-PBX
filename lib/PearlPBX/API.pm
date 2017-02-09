
package PearlPBX::API;

use warnings;
use strict;

use JSON::XS;
use Encode;
use PearlPBX::Logger;
use PearlPBX::Const;
use PearlPBX::ScalarUtils qw/trim/;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (
    api_dialer
);

sub _ok {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $res = $req->new_response(200);
    $res->body("OK\n");
    return $res->finalize($env);
}

sub _error {
    my $env  = shift;
    my $code = shift;
    my $desc = shift;

    my $req = Plack::Request->new($env);
    my $res = $req->new_response ($code);
    Err($desc);
    $res->body($desc);
    return $res->finalize($env);
}

sub api_dialer {
    my $env    = shift;
    my $req    = Plack::Request->new($env);
    my $params = $req->parameters;

    my $src = trim ( $params->{src} // '' );
    if ( $src eq '' ) {
        return _error($env, 400, "Parameter 'src' is required.");
    }
    my $dst = trim ( $params->{dst} // '' );
    if ( $dst eq '' ) {
        return _error ($env, 400, "Parameter 'dst' is required.");
    }
    my $taskName = trim ($params->{taskName} // '');
    if ( $taskName eq '' ) {
        return _error ($env, 400, "Parameter 'taskName' is required.");
    }
    my $notifyURL = trim ( $params->{notifyURL} // '' ); # Optional parameter
    my @cmdparams = ( "/usr/sbin/PearlPBX-rocket-dialer.pl","--src", $src,"--dst", $dst,
        "--taskName", $taskName );

    if ( $notifyURL ne '' ) {
       push @cmdparams, "--notifyURL", $notifyURL;
    }

    system(@cmdparams);
    return _ok($env);
}

1;

