package PearlPBX::Const;

use warnings;
use strict;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw(
    DEVEL_MODE
    WWW_ROOT
    TEMPLATES_PATH
    MSG_SERVER_ERROR
    MSG_TEMP_UNAVAIL
    OK
    FAIL
    ERROR
    PEARLPBX_CONFIG
);

use constant DEVEL_MODE     => $ENV{STARMAN_DEBUG} ? 1 : 0;
use constant WWW_ROOT       => $ENV{FRONTEND_ROOT} // '/var/www/pearlpbx2';
use constant TEMPLATES_PATH => WWW_ROOT . '/templates';

use constant MSG_SERVER_ERROR => 'Server error. Try later, please.';
use constant MSG_TEMP_UNAVAIL => 'Temporary unavailable. We are sorry.';

use constant OK => 'OK';
use constant FAIL => 'FAIL';
use constant ERROR => 'ERROR';

use constant PEARLPBX_CONFIG => '/etc/PearlPBX/asterisk-router.conf';

1;

