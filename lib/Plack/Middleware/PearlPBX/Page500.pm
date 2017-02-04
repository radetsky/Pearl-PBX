package Plack::Middleware::PearlPBX::Page500;

use strict;
use warnings;
use parent qw/Plack::Middleware/;

use Try::Tiny;
use Devel::StackTrace;

use PearlPBX::Logger;
use PearlPBX::Pages;

sub call {
    my ( $self, $env ) = @_;

    my $trace;
    local $SIG{__DIE__} = sub {
        $trace = Devel::StackTrace->new( ignore_package => __PACKAGE__ );
        die @_;
    };
    my $caught = undef;
    my $res    = try {
        $self->app->($env);
    }
    catch {
        $caught = $_;
    };

    if ( $caught ) {
        Err ( $caught );
        Err ( $trace->as_string );
        undef $trace;
        return page_500($env);
    }

    undef $trace;
    return $res;
}

1; 

