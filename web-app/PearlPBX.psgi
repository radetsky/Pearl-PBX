#!/usr/bin/perl

use warnings;
use strict;

# We use Plack*
use Plack::Request;
use Plack::Builder;
use Plack::App::Directory;

# Own modules to present Pages and Actions
use PearlPBX::Config -load;
use PearlPBX::Pages;
use PearlPBX::Actions;
use PearlPBX::API;
use PearlPBX::DB;

use PearlPBX::Const;

use Plack::Middleware::PearlPBX::Authenticate;
use Plack::Middleware::PearlPBX::Page500;
use Plack::Middleware::StackTrace;
use Plack::Middleware::Session;
use Plack::Session::State::Cookie;
use Plack::Session::Store::Cache;

use POSIX::AtFork;

POSIX::AtFork->add_to_child( sub { PearlPBX::DB->new("pearlpbx.conf"); } );

# -------------- Plack application ------------

my $app = builder {
    if ( $ENV{STARMAN_DEBUG} ) {
        enable "StackTrace", force => 1;
    }
    else {
        # Enable Page_500 instead of stacktrace on the deployment
        enable 'PearlPBX::Page500';
    }

    enable 'Session';

    mount "/" => builder {
        mount "/api" => builder {
            mount "/dialer" => builder { \&api_dialer };
        };
        mount "/login"        => builder { \&page_login };
        mount "/action/login" => builder { \&action_login };
	    mount "/action/logout" => builder { \&action_logout };
        mount "/img" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/img' )->to_app;
        mount "/css" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/css' )->to_app;
        mount "/js" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/js' )->to_app;
        mount "/html" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/html' )->to_app;
        mount "/" => builder {
            enable 'PearlPBX::Authenticate';
            mount "/"      => builder { \&page_index };
            mount "/index" => builder { \&page_index };
        };
    };
};

