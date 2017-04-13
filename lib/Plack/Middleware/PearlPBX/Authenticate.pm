#!/usr/bin/perl

package Plack::Middleware::PearlPBX::Authenticate;

use warnings;
use strict;

use parent qw(Plack::Middleware);
use Plack;
use Plack::Response;
use Plack::Request;

use PearlPBX::HttpUtils qw/http_accept_lang/;
use PearlPBX::Logger;


sub call {
    my ( $this, $env ) = @_;
    my $req  = Plack::Request->new($env);

    # Determine the best language
    my $lang = http_accept_lang($env->{'HTTP_ACCEPT_LANGUAGE'});
    my $session = $req->session;
    $req->session->{lang} = $lang // 'en';

    my $path = $req->path_info();

    Debug( "Request -> " . $path );

    # Page and action 'login' do not need authenticated user
    if ( ( $path eq '/login') || ( $path eq '/action/login') ) {
      return $this->app->($env);
    }

    # Let's check a session.
    unless ( defined ( $session->{account} ) ) {
        return $this->unauthenticated ( $req, $env );
    }

    Debugf( 'Current session: %s', $session );
    return $this->app->($env);
}

sub unauthenticated {
    my ( $this, $req, $env ) = @_;

    Debug("No session information. Redirect to /login");
    $req->session_options->{expire} = 1;
    my $res = $req->new_response( 302, [ 'Location' => '/login' ] );
    $res->body('unauthenticated');

    return $res->finalize();
}

1;

__END__
