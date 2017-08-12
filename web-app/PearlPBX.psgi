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
use PearlPBX::Route;
use PearlPBX::API;
use PearlPBX::DB;
use PearlPBX::SIP;
use PearlPBX::Queues;
use PearlPBX::Trunkgroups;

use PearlPBX::Const;

use Plack::Middleware::PearlPBX::Authenticate;
use Plack::Middleware::PearlPBX::Page500;
use Plack::Middleware::StackTrace;
use Plack::Middleware::Session;
use Plack::Session::State::Cookie;
use Plack::Session::Store::Cache;
use Plack::App::Proxy;

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
        mount "/login"         => builder { \&page_login    };
        mount "/action/login"  => builder { \&action_login  };
    	mount "/action/logout" => builder { \&action_logout };
        mount "/img" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/img' )->to_app;
        mount "/css" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/css' )->to_app;
        mount "/js" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/js' )->to_app;
        mount "/html" =>
          Plack::App::Directory->new( root => WWW_ROOT . '/html' )->to_app;
        mount "/asterisk/rawman" =>
          Plack::App::Proxy->new( remote => "http://127.0.0.1:8088/asterisk/rawman")->to_app;
        mount "/" => builder {
            enable 'PearlPBX::Authenticate';
            mount "/"      => builder { \&page_index };
            mount "/index" => builder { \&page_index };
            mount "/modules.pl" => builder { \&api_modules };
            mount "/route" => builder {
                mount "/manager" => builder {
                    mount "/credentials" => builder { \&route_manager_credentials };
                };
                mount "/getulines"    => builder { \&route_get_ulines };
                mount "/list"         => builder { \&route_list };
                mount "/getdirection" => builder { \&route_get_direction };
                mount "/getrouting"   => builder { \&route_get_routing   };
                mount "/addprefix"    => builder { \&route_addprefix     };
                mount "/removeprefix" => builder { \&route_removeprefix  };
                mount "/addrouting"   => builder { \&route_addrouting    };
                mount "/removerouting" => builder { \&route_removerouting };
                mount "/savedirection" => builder { \&route_savedirection };
                mount "/removedirection" => builder { \&route_removedirection };
                mount "/adddirection"  => builder { \&route_adddirection };

            };
            mount "/sip" => builder {
                mount "/monitor" => builder {
                    mount "/get_sip_db" => builder { \&sipdb_monitor_get };
                };
                mount "/list" => builder {
                    mount "/internal" => builder { \&sipdb_list_internal };
                    mount "/external" => builder { \&sipdb_list_external };
                };
                mount "/getuser"   => builder { \&sipdb_getuser };
                mount "/newsecret" => builder { \&newsecret };
                mount "/setuser"   => builder { \&sipdb_setuser };
                mount "/adduser"   => builder { \&sipdb_adduser };
                mount "/deluser"   => builder { \&sipdb_deluser };
                mount "/setpeer"   => builder { \&sipdb_setpeer };
                mount "/getpeer"   => builder { \&sipdb_getpeer };
            };
            mount "/queues" => builder {
                mount "/list"        => builder { \&queues_list };
                mount "/getqueue"    => builder { \&queues_getqueue };
                mount "/setqueue"    => builder { \&queues_setqueue };
                mount "/delqueue"    => builder { \&queues_delqueue };
                mount "/listmembers" => builder { \&queues_listmembers };
                mount "/addmember"   => builder { \&queues_addmember };
                mount "/removemember" => builder { \&queues_removemember };
            };
            mount "/trunkgroups" => builder {
                mount "/list"       => builder { \&trunkgroups_list };
                mount "/add"        => builder { \&trunkgroups_add  };
                mount "/id"         => builder { \&trunkgroups_id   };
                mount "/channels"   => builder { \&trunkgroups_channels };
                mount "/addmember"  => builder { \&trunkgroups_addmember };
                mount "/delmember"  => builder { \&trunkgroups_delmember };
                mount "/update"     => builder { \&trunkgroups_update };
                mount "/remove"     => builder { \&trunkgroups_remove };
            };
        };
    };
};

