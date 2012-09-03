#!/bin/sh

#yum install screen postgresql-server postgresql vim perl-DBI perl-DBD-Pg wget 
#cd /tmp
#wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
# wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#rpm -ivh ./rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
# wget rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#yum install perl-Data-Dumper 
#yum install httpd httpd-devel httpd-tools 

install -m 755 -o asterisk:asterisk agi-bin/NetSDS-AGI-integration.pl /var/lib/asterisk/agi-bin
install -m 755 -o asterisk:asterisk agi-bin/NetSDS-route.pl /var/lib/asterisk/agi-bin
install -m 755 -o asterisk:asterisk bin/* /usr/bin/ 
install -d -m 755 -o asterisk:asterisk /etc/NetSDS
install -m 644 -o asterisk:asterisk etc/NetSDS/asterisk-router.conf /etc/NetSDS
ln -sf /etc/NetSDS /etc/PearlPBX
install -m 644 -o asterisk:asterisk etc/apache2/sites-available/pearlpbx /etc/httpd/conf.d/pearlpbx.conf 
install -m 755 -o root:root etc/init.d/pearpbx-parsequeuelogd /etc/init.d 

install -m 644 -o root:root lib/*.pm /usr/share/perl5
cp -a lib/PearlPBX /usr/share/perl5
cp -a lib/NetSDS /usr/share/perl5

install -m 755 -o asterisk:asterisk sbin/* /usr/sbin/ 






