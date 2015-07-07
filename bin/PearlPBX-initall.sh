#!/bin/sh

first_run_pearlpbx() { 

mkdir -p /var/run/NetSDS 
ln -sf /etc/NetSDS /etc/PearlPBX
/usr/bin/postgresql-setup initdb
cp /var/lib/pgsql/data/pg_hba.conf /tmp/pg_hba.conf 
cat /tmp/pg_hba.conf | sed 's/ident$/trust/' >/var/lib/pgsql/data/pg_hba.conf
rm /tmp/pg_hba.conf
cp  /var/lib/pgsql/data/pg_hba.conf /tmp/pg_hba.conf 
cat /tmp/pg_hba.conf | sed 's/peer$/trust/' >/var/lib/pgsql/data/pg_hba.conf
systemctl start postgresql.service
psql -U postgres -f /etc/NetSDS/sql/create_user_asterisk.sql
createdb -U postgres asterisk -O asterisk
psql -U asterisk -f /etc/NetSDS/sql/postgresql_config.sql 
psql -U asterisk -f /etc/NetSDS/sql/postgresql_cdr.sql 
psql -U asterisk -f /etc/NetSDS/sql/postgresql_voicemail.sql 
psql -U asterisk -f /etc/NetSDS/sql/pearlpbx.sql 
#psql -U postgres -f /etc/NetSDS/sql/asterisk.sql
psql -U asterisk -f /etc/NetSDS/sql/callback.sql
psql -U asterisk -f /etc/NetSDS/sql/directions_list.sql
psql -U asterisk -f /etc/NetSDS/sql/directions.sql
psql -U asterisk -f /etc/NetSDS/sql/sip_conf.sql
psql -U asterisk -f /etc/NetSDS/sql/extensions_conf.sql
psql -U asterisk -f /etc/NetSDS/sql/route.sql
psql -U asterisk -f /etc/NetSDS/sql/local_route.sql
psql -U asterisk -f /etc/NetSDS/sql/cal.sql
psql -U asterisk -f /etc/NetSDS/sql/ivr.sql
FIXME !!!! # Найти пропавший asterisk.conf
mv -f /etc/PearlPBX/asterisk/* /etc/asterisk/
chown asterisk:asterisk /etc/asterisk -R 
/usr/sbin/PearlPBX-gui-passwd.pl admin admin
/usr/bin/ulines.pl
mkdir /var/www/pearlpbx/files
chown apache:apache /var/www/pearlpbx/files
mkdir /usr/share/asterisk/sounds/ru/pearlpbx
chown apache:apache /usr/share/asterisk/sounds/ru/pearlpbx
systemctl stop postgresql 

firewall-cmd --permanent  --add-service=http
firewall-cmd --permanent  --add-port=5060/udp 
firewall-cmd --permanent  --add-port=5060/tcp 
firewall-cmd --permanent  --add-port=5061/tcp 
firewall-cmd --reload 

echo "Installed" >/etc/sysconfig/PearlPBX

}

	if [ -f /etc/sysconfig/PearlPBX ] 
	then
		echo OK
	else 
		first_run_pearlpbx
	fi
	exit 0

