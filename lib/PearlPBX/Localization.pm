package PearlPBX::Localization; 

use warnings; 
use strict; 

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (TRANSLATE translate);
use constant TRANSLATE => {
    'ru' => { }, 
}; 

sub translate {
    my $lang   = shift;
    my $phrase = shift;
    my $res;

    if ( exists( TRANSLATE->{$lang}->{$phrase} ) ) {
        $res = TRANSLATE->{$lang}->{$phrase};
    } else {
        # If message starts with '_', it's identifier, not english phrase.
        # Do not put this identifier itself, try to translate to english or retuen empty line.
        if (rindex($phrase, '_', 0) == 0) {
            $res = TRANSLATE->{en}->{$phrase} // "";
        } else {
            $res = $phrase;
        }
    }
    return @_ ? sprintf($res, @_) : $res;
}

1; 
