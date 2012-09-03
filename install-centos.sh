#!/bin/sh

#yum install screen postgresql-server postgresql vim perl-DBI perl-DBD-Pg wget 
#cd /tmp
#wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
# wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#rpm -ivh ./rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
# wget rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#yum install perl-Data-Dumper 
#yum install httpd httpd-devel httpd-tools 

install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-AGI-integration.pl /var/lib/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-route.pl /var/lib/asterisk/agi-bin

install -m 755 -o asterisk -g asterisk bin/* /usr/bin/ 

install -d -m 755 -o asterisk -g asterisk /etc/NetSDS
install -m 644 -o asterisk -g asterisk etc/NetSDS/asterisk-router.conf /etc/NetSDS
ln -sf /etc/NetSDS /etc/PearlPBX
install -m 644 -o asterisk -g asterisk etc/apache2/sites-available/pearlpbx /etc/httpd/conf.d/pearlpbx.conf 
install -m 755 -o root -g root etc/init.d/pearlpbx-parsequeuelogd /etc/init.d 
mv -f /etc/asterisk /etc/asterisk.pearlpbx-moved-old-configs-here 
install -d -m 755 -o asterisk -g asterisk etc/asterisk /etc 
cp -a etc/asterisk/* /etc/asterisk

install -m 644 -o root -g root lib/*.pm /usr/share/perl5
cp -a lib/PearlPBX /usr/share/perl5
cp -a lib/NetSDS /usr/share/perl5

install -m 755 -o asterisk -g asterisk sbin/* /usr/sbin/ 

mkdir -p /usr/share/pearlpbx
cp -av share/reports /usr/share/pearlpbx/

cp -av sounds/* /var/lib/asterisk/sounds 

mkdir -p /var/lib/tftpboot 
cp -a var/lib/tftpboot/* /var/lib/tftpboot 

psql -U postgres -f sql/create_user_asterisk.sql
psql -U postgres -f sql/asterisk.sql 

install -d -m 755 -o asterisk -g asterisk /var/www/pearlpbx 
cp -a web/* /var/www/pearlpbx/ 


