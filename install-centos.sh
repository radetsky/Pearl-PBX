#!/bin/sh

mkdir -p /var/run/NetSDS
chmod 777 /var/run/NetSDS

install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-AGI-integration.pl /var/lib/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-route.pl /var/lib/asterisk/agi-bin

install -m 755 -o asterisk -g asterisk bin/* /usr/bin/ 
install -m 755 -o asterisk -g asterisk sbin/* /usr/sbin/

install -d -m 755 -o asterisk -g asterisk /etc/NetSDS
install -m 644 -o asterisk -g asterisk etc/NetSDS/asterisk-router.conf /etc/NetSDS
ln -sf /etc/NetSDS /etc/PearlPBX

install -m 644 -o asterisk -g asterisk etc/apache2/sites-available/pearlpbx /etc/httpd/conf.d/pearlpbx.conf 

install -m 755 -o root -g root etc/init.d/pearlpbx-parsequeuelogd /etc/init.d 
chkconfig pearlpbx-parsequeuelogd on 
install -m 644 -o root -g root etc/monit.d/ /etc/monit.d/

install -m 755 -o root -g root etc/init.d/pearlpbx-hangupd /etc/init.d
chkconfig pearlpbx-hangupd on 
install -m 755 -o root -g root etc/monit.d/pearlpbx-hangupd /etc/monit.d

install -m 755 -o root -g root etc/monit.d/asterisk /etc/monit.d/

install -m 755 -o root -g root etc/cron.d/* /etc/cron.d/ 


#mv -f /etc/asterisk /etc/asterisk.pearlpbx-moved-old-configs-here 
#install -d -m 755 -o asterisk -g asterisk /etc/asterisk 
cp -a etc/asterisk1.8/* /etc/asterisk

install -m 644 -o root -g root lib/*.pm /usr/share/perl5
cp -a lib/PearlPBX /usr/share/perl5
cp -a lib/Pearl /usr/share/perl5
cp -a lib/NetSDS /usr/share/perl5

mkdir -p /usr/share/pearlpbx
cp -av share/reports /usr/share/pearlpbx/

cp -av sounds/* /usr/share/asterisk/sounds 

mkdir -p /var/lib/tftpboot 
chmod 777 /var/lib/tftpboot
cp -a var/lib/tftpboot/* /var/lib/tftpboot 

/etc/init.d/postgresql initdb
cp var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf 
/etc/init.d/postgresql start 
psql -U postgres -f sql/create_user_asterisk.sql
psql -U asterisk -f sql/asterisk.sql 
psql -U asterisk -f sql/directions_list.sql
psql -U asterisk -f sql/directions.sql 
psql -U asterisk -f sql/sip_conf.sql 
psql -U asterisk -f sql/extensions_conf.sql 
psql -U asterisk -f sql/route.sql 

install -d -m 755 -o asterisk -g asterisk /var/www/pearlpbx 
cp -a web/* /var/www/pearlpbx/ 

chkconfig asterisk on 
chkconfig postgresql on 
chkconfig httpd on 
chkconfig monit on 

/usr/sbin/PearlPBX-gui-passwd.pl admin admin 


