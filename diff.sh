#!/bin/sh 

colordiff -r /opt/local/lib/perl5/vendor_perl/PearlPBX ./lib/PearlPBX
colordiff /opt/local/lib/perl5/vendor_perl/Pearl.pm ./lib/Pearl.pm 
colordiff -r /opt/local/lib/perl5/vendor_perl/Pearl ./lib/Pearl 
colordiff -r /usr/share/pearlpbx/reports ./share/reports
colordiff -r /usr/share/pearlpbx/modules ./share/modules
colordiff -r /usr/share/pearlpbx/provision ./share/provision 
colordiff -r /opt/local/apache2/htdocs ./web

