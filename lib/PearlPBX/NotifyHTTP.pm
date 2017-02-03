package PearlPBX::NotifyHTTP;

use warnings;
use strict;

use LWP::UserAgent;
use HTTP::Request;

use PearlPBX::Logger;

our @EXPORT_OK = qw( notify_http );
use Exporter;
use parent 'Exporter';

my $UA;

sub _init {
    if (!$UA) {
        $UA = LWP::UserAgent->new();
        $UA->timeout(10);
    }
    return $UA;
}

sub notify_http {
    my ($args) = @_;
    $args = { @_ } unless ref $args;

    _init();
    Debugf("Sending http notification: %s", $args);
    my $req = HTTP::Request->new ( POST => $args->{uri} );
    $req->content_type($args->{cont_type} // 'application/json');
    $req->content($args->{post_data});
    if ($args->{signature}) {
        $req->header('X-Signature' => $args->{signature});
    }
    my $res = $UA->request($req);
    Infof("Notification sent to %s, result %s", $args->{uri}, $res->status_line);
    if ( !$res->is_success ) {
        Errf("Request to %s, with data %s failed: Status line %s, Body\n%s", $args->{uri}, $args->{post_data}, $res->status_line, $res->content);
    }
    return $res->is_success ? 1 : undef;
}

1;
