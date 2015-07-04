#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-mail.pl
#
#        USAGE:  ./PearlPBX-mail.pl
#
#  DESCRIPTION:  Mail faxes to $ARGV[1] as attach ARGV[0] from ARGV[2] and HTML text
#      OPTIONS:  Filename to attach , email to send 
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  22.05.2015
#     REVISION:  001
#===============================================================================


use 5.8.0;
use strict;
use warnings;

$| = 1;

Mail->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Mail;

use base 'PearlPBX::IVR';
use Data::Dumper;
use NetSDS::Util::String;  
use MIME::Base64; 
use NetSDS::Util::DateTime;
use File::Basename; 
use MIME::Lite; 


sub process {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <filename> <email> <src>',
            3
        );
        exit(-1);
    }
    unless ( defined( $ARGV[1] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <filename> <email> <src>',
            3
        );
        exit(-1);
    }
    unless ( defined( $ARGV[2] ) ) {
        $this->agi->verbose(
            "Usage: "
              . $this->name
              . ' <filename> <email> <src>',
            3
        );
        exit(-1);
    }
    

    $this->_mail($ARGV[0], $ARGV[1], $ARGV[2]); 

    exit(0);
}


sub _mail { 

    my ($this, $realfilename, $email, $src) = @_; 

    my $from       = 'fax@radiogroup.com.ua'; 
    my $to         = $email;

    my $subject = 'Принятый факс с номера: ' . $src;
    my $body = "С уважением, PearlPBX\n";

    ### Create the multipart "container":
    my $msg = MIME::Lite->new(
        From    => $from,
        To      => $to,
        Subject => $subject,
        Type    =>'multipart/mixed'
    );

    my $fname = basename($realfilename);
    my $url = "<a href='cid:$fname'>$fname</a>"; 
    my $text = $url . "\n" . "--\n" . $body; 
    
    $msg->attach(
        Type        => 'application/pdf',
        Path        => $realfilename,
        Id          => $fname,
        Filename    => $fname,
        Disposition => 'attachment'
    );
    
    ### Add the text message part:
    ### (Note that "attach" has same arguments as "new"):
    $msg->attach (
        Type     =>'text/html; charset=utf-8',
        Data     => $text, 
    );

    $msg->send ('smtp','smtp.umh.kiev.ua');

    return 1; 

} 


1; 


