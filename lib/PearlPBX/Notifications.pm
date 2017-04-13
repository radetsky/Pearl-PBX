package PearlPBX::Notifications;

use warnings;
use strict;

use Plack::Request;
use PearlPBX::Localization;
use PearlPBX::HttpUtils qw/http_accept_lang/;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (MessageBox PopMessages);

sub MessageBox {
    my ( $env, $msg, $type ) = @_;

    my $session = Plack::Request->new($env)->session;

    my $translated = translate ( $session->{lang} // http_accept_lang ($env->{'HTTP_ACCEPT_LANGUAGE'}) // 'en', $msg);
    push @{ $env->{'pearlpbx.messages'} },
        {
        text => $translated,
        type => $type // 'success'
        };
}

sub PopMessages {
    my $env  = shift;
    my $msgs = $env->{'pearlpbx.messages'};
    $env->{'pearlpbx.messages'} = [];
    return $msgs;
}

1;


