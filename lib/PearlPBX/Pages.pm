package PearlPBX::Pages;

use warnings;
use strict;

use Encode;
use JSON::XS;
use PearlPBX::Const;
use PearlPBX::HttpUtils qw(http_accept_lang);
use PearlPBX::Notifications;
use PearlPBX::Localization;

use feature 'state';

use Template;
use Template::Context;
use Template::Plugins;
use Template::Filters;
use Template::Stash::XS;
use Template::Parser;
use Template::Iterator;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (
    page_login
    page_index
);

sub tmpl_finalize {
    my $env     = shift;
    my $vars    = shift;
    my $req     = Plack::Request->new($env);
    my $session = $req->session;

    $vars->{username}      = $session->{account};
    $vars->{translate}     = sub { return translate( $session->{lang}//http_accept_lang($env->{'HTTP_ACCEPT_LANGUAGE'}), @_ ); };
    $vars->{messages}      = PopMessages($env);

    return $vars;
}


sub page_login {
    my $env     = shift;
    my $req     = Plack::Request->new($env);
    my $res     = $req->new_response(200);
    my $session = $req->session;
    my $params  = $req->parameters->as_hashref;

    my $template = Template->new(
        {
            INCLUDE_PATH => TEMPLATES_PATH,
            INTERPOLATE  => 0,
        }
    ) or die "$Template::ERROR\n";

    my $template_vars = { email => $params->{log_username}, };

    $template_vars = tmpl_finalize( $env, $template_vars );

    my $processed = '';
    $template->process( 'login.tmpl', $template_vars, \$processed )
      or die $template->error();
    $res->body($processed);

    return $res->finalize($env);
}

sub page_index {
    my $env     = shift;
    my $req     = Plack::Request->new($env);
    my $res     = $req->new_response(200);
    my $session = $req->session;
    my $params  = $req->parameters->as_hashref;

    my $template = Template->new(
        {
            INCLUDE_PATH => TEMPLATES_PATH,
            INTERPOLATE  => 0,
        }
    ) or die "$Template::ERROR\n";

    my $template_vars = { email => $params->{log_username}, };

    $template_vars = tmpl_finalize( $env, $template_vars );

    my $processed = '';
    $template->process( 'index_v1.tmpl', $template_vars, \$processed )
      or die $template->error();
    $res->body($processed);

    return $res->finalize($env);
}

1;

