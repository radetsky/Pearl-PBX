#!/bin/sh

echo "Attention: this file is unchecked and for demonstration only how PearlPBX must be installed."
echo "Preferred way to install PearlPBX is --  yum install PearlPBX from PearlPBX repository"
echo "Use this software on your own risk!" 

# Install new repos 
yum install http://www.pearlpbx.com/download/RPMS/noarch/epel-release-6-8.noarch.rpm 
yum install http://www.pearlpbx.com/download/RPMS/x86_64/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
wget -O /etc/yum.repos.d/PearlPBX.repo http://www.pearlpbx.com/download/PearlPBX.repo 

# Install deps 
yum install asterisk asterisk-pgsql asterisk-voicemail postgresql-server postgresql perl-NetSDS perl-Class-Accessor-Class perl-Class-Accessor perl-Template-Toolkit perl-NetSDS-Asterisk perl-asterisk-perl httpd asterisk-sounds-ru-wav asterisk-sounds-ru-gsm asterisk-sounds-ru-alaw uuid-pgsql perl-CGI-Session perl-CGI-Session-Auth system-config-network-tui monit pwgen perl-File-Tail tftp-server sox 

# Copy files 
mkdir -p /var/run/NetSDS
chmod 777 /var/run/NetSDS

mkdir -p /usr/share/asterisk/agi-bin 

install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-AGI-integration.pl /usr/share/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-route.pl /usr/share/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/PearlPBX* /usr/share/asterisk/agi-bin

install -m 755 -o asterisk -g asterisk bin/* /usr/bin/ 
install -m 755 -o asterisk -g asterisk sbin/* /usr/sbin/

mkdir -p /etc/NetSDS
ln -sf /etc/NetSDS /etc/PearlPBX 
install -m 644 -o asterisk -g asterisk etc/NetSDS/asterisk-router.conf /etc/NetSDS
install -m 644 -o asterisk -g asterisk etc/apache2/sites-available/pearlpbx /etc/httpd/conf.d/pearlpbx.conf 
install -m 755 -o root -g root etc/init.d/pearlpbx-parsequeuelogd /etc/init.d 
install -m 644 -o root -g root etc/monit.d/ /etc/monit.d/
install -m 755 -o root -g root etc/init.d/pearlpbx-hangupd /etc/init.d
install -m 755 -o root -g root etc/monit.d/pearlpbx-hangupd /etc/monit.d
install -m 755 -o root -g root etc/monit.d/asterisk /etc/monit.d/
install -m 755 -o root -g root etc/init.d/PearlPBX /etc/init.d 
chkconfig PearlPBX on 

install -m 644 -o root -g root etc/cron.d/* /etc/cron.d/ 
cp -a etc/asterisk1.8/* /etc/asterisk

install -m 644 -o root -g root lib/*.pm /usr/share/perl5
cp -a lib/PearlPBX /usr/share/perl5
cp -a lib/Pearl /usr/share/perl5
cp -a lib/NetSDS /usr/share/perl5

mkdir -p /usr/share/pearlpbx
cp -av share/reports /usr/share/pearlpbx/

cp -av sounds/* /usr/share/asterisk/sounds 

ln -sf /usr/share/asterisk/sounds /var/lib/asterisk/sounds 
ln -sf /usr/share/asterisk/agi-bin /var/lib/asterisk/agi-bin 

mkdir -p /var/lib/tftpboot 
chmod 777 /var/lib/tftpboot
cp -a var/lib/tftpboot/* /var/lib/tftpboot 

install -d -m 755 -o asterisk -g asterisk /var/www/pearlpbx 
cp -a web/* /var/www/pearlpbx/ 

chkconfig asterisk off
chkconfig postgresql off 
chkconfig httpd on
chkconfig monit on

/usr/sbin/PearlPBX-gui-passwd.pl admin admin 


