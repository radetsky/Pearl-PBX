#!/bin/sh


install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-AGI-integration.pl /usr/share/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-route.pl /usr/share/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/PearlPBX*.pl /usr/share/asterisk/agi-bin 

install -m 755 -o root -g asterisk bin/* /usr/bin/ 
install -m 755 -o root -g asterisk sbin/* /usr/sbin/

chmod u+s /usr/bin/PearlPBX-tftpprovisor.pl 

install -m 755 -o root -g root etc/init.d/pearlpbx-parsequeuelogd /etc/init.d 
install -m 644 -o root -g root etc/monit.d/ /etc/monit.d/
install -m 755 -o root -g root etc/init.d/pearlpbx-hangupd /etc/init.d
install -m 755 -o root -g root etc/monit.d/pearlpbx-hangupd /etc/monit.d
install -m 755 -o root -g root etc/monit.d/asterisk /etc/monit.d

install -m 644 -o root -g root lib/*.pm /usr/share/perl5
cp -a lib/PearlPBX /usr/share/perl5
cp -a lib/Pearl /usr/share/perl5
cp -a lib/NetSDS /usr/share/perl5

mkdir -p /usr/share/pearlpbx
cp -av share/reports /usr/share/pearlpbx/
#cp -av sounds/* /usr/share/asterisk/sounds 

mkdir -p /var/lib/tftpboot 
chmod 777 /var/lib/tftpboot
cp -a var/lib/tftpboot/* /var/lib/tftpboot 

install -d -m 755 -o asterisk -g asterisk /var/www/pearlpbx 
cp -av web/* /var/www/pearlpbx/ 


