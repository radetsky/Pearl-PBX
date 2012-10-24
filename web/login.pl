#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  route.pl
#
#  DESCRIPTION:  PearlPBX login procedure 
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Radetsky
#      VERSION:  1.0
#      CREATED:  22.10.2012
#     REVISION:  001
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Pearl::Auth;

my $pearl = Pearl->new();

my $cgi = $pearl->{cgi}; 
my $auth = Pearl::Auth->new ( { config => "/etc/PearlPBX/asterisk-router.conf", 
                                cgi => $cgi,
                            } );

my $proto = $cgi->https ? 'https' : 'http';

if ( defined ( $pearl->{cgi}->param('logout') ) )  { 
    $auth->logout();     
    print $cgi->redirect(                                                                                               
    -location => $proto.'://'.$ENV{'SERVER_NAME'}.                                                                                    
            ($ENV{'SERVER_PORT'} eq '80' ? '' : ':'.$ENV{'SERVER_PORT'}).                                                       
            '/login.html',
    -cookie => $auth->cookie                                                                                                       
    );
    exit(0);
}


if ( defined ( $pearl->{cgi}->param('authentication') ) ) { 
    my $loggedIn = $auth->authenticate($cgi); 
    unless ( defined ( $loggedIn) ) {
        $pearl->htmlHeader; 
        print "ERROR:ACCESS DENIED.";
        exit(0);  
    }
    $pearl->htmlHeader;
    print "OK:$loggedIn";
    exit(0); 
}

my $login = $auth->login($pearl->{cgi}, 1);

if(defined $login){
    print $cgi->redirect(                                                                                               
	-location => $proto.'://'.$ENV{'SERVER_NAME'}.                                                                                    
    	    ($ENV{'SERVER_PORT'} eq '80' ? '' : ':'.$ENV{'SERVER_PORT'}).                                                       
    	    '/index.html',
    	-cookie => $auth->cookie                                                                                                   
    );
} else {
    print $cgi->redirect(                                                                                               
	-location => $proto.'://'.$ENV{'SERVER_NAME'}.                                                                                    
    	    ($ENV{'SERVER_PORT'} eq '80' ? '' : ':'.$ENV{'SERVER_PORT'}).                                                       
    	    '/login.html#no'
    );
}

exit(0);
