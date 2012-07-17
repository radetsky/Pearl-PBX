#!/bin/sh 

colordiff -r /opt/local/lib/perl5/vendor_perl/PearlPBX ./lib/PearlPBX
colordiff /opt/local/lib/perl5/vendor_perl/Pearl.pm ./lib/Pearl.pm 
colordiff -r /usr/share/pearlpbx/reports ./share/reports
colordiff -r /opt/local/apache2/htdocs ./web

