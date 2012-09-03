#!/bin/sh

#yum install screen postgresql-server postgresql vim perl-DBI perl-DBD-Pg wget 
#cd /tmp
#wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
# wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#rpm -ivh ./rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
# wget rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#yum install perl-Data-Dumper 

install -m755 agi-bin/NetSDS-AGI-integration.pl /var/lib/asterisk/agi-bin
install -m755 agi-bin/NetSDS-route.pl /var/lib/asterisk/agi-bin






