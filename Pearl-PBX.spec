Name: Pearl-PBX
Version: 1.0
Release: centos6

Summary: Web GUI for Asterisk written by Alex Radetsky <rad@rad.kiev.ua> 

License: GPL

Group: Networking/Other
Url: http://www.pearlpbx.com/

Packager: Alex Radetsky <rad@rad.kiev.ua>

BuildArch: noarch
Source0: %name-%version.tar

#BuildRequires: make
#BuildRequires: perl-CGI perl-Class-Accessor-Class perl-Config-General perl-DBI perl-Encode perl-FCGI perl-Unix-Syslog
#BuildRequires: perl-NetSDS perl-Class-Accessor-Class perl-Class-Accessor

Requires: asterisk > 11
Requires: asterisk-postgresql
Requires: postgresql-server
Requires: postgresql
Requires: perl-NetSDS
Requires: perl-Class-Accessor-Class 
Requires: perl-Class-Accessor 
Requires: perl-Template-Toolkit 
Requires: perl-NetSDS-Asterisk 
Requires: perl-asterisk-perl 
Requires: httpd 
Requires: asterisk-sounds-ru-wav
Requires: asterisk-sounds-ru-gsm
Requires: asterisk-sounds-ru-alaw
Requires: uuid-pgsql
Requires: perl-CGI-Session
Requires: perl-CGI-Session-Auth
Requires: system-config-network-tui 
Requires: monit 

%description
Web GUI for Asterisk written by Alex Radetsky <rad@rad.kiev.ua>

%prep
%setup -n %name-%version

%build

%install

rm -rf %{buildroot}

mkdir -p %buildroot/var/run/NetSDS
chmod 777 %buildroot/var/run/NetSDS

mkdir -p %buildroot/var/lib/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-AGI-integration.pl %buildroot/var/lib/asterisk/agi-bin
install -m 755 -o asterisk -g asterisk agi-bin/NetSDS-route.pl %buildroot/var/lib/asterisk/agi-bin

install -D -m 755 -o asterisk -g asterisk bin/* %buildroot/usr/bin/ 
install -D -m 755 -o asterisk -g asterisk sbin/* %buildroot/usr/sbin/

install -d -m 755 -o asterisk -g asterisk %buildroot/etc/NetSDS
install -m 644 -o asterisk -g asterisk etc/NetSDS/asterisk-router.conf %buildroot/etc/NetSDS
ln -sf %buildroot/etc/NetSDS %buildroot/etc/PearlPBX

install -D -m 644 -o asterisk -g asterisk etc/apache2/sites-available/pearlpbx %buildroot/etc/httpd/conf.d/pearlpbx.conf 

install -D -m 755 -o root -g root etc/init.d/pearlpbx-parsequeuelogd %buildroot/etc/init.d 
install -D -m 644 -o root -g root etc/monit.d/ %buildroot/etc/monit.d/

install -D -m 755 -o root -g root etc/init.d/pearlpbx-hangupd %buildroot/etc/init.d
install -D -m 755 -o root -g root etc/monit.d/pearlpbx-hangupd %buildroot/etc/monit.d

install -D -m 755 -o root -g root etc/monit.d/asterisk %buildroot/etc/monit.d/

install -D -m 755 -o root -g root etc/cron.d/* %buildroot/etc/cron.d/ 

install -D -m 755 -o asterisk -g asterisk etc/asterisk1.8/* %buildroot/etc/asterisk

install -D -m 644 -o root -g root lib/*.pm %buildroot/usr/share/perl5

cp -a lib/PearlPBX %buildroot/usr/share/perl5
cp -a lib/Pearl %buildroot/usr/share/perl5
cp -a lib/NetSDS %buildroot/usr/share/perl5

mkdir -p %buildroot/usr/share/pearlpbx
cp -av share/reports %buildroot/usr/share/pearlpbx/

cp -av sounds/* %buildroot/usr/share/asterisk/sounds 

mkdir -p %buildroot/var/lib/tftpboot 
chmod 777 %buildroot/var/lib/tftpboot
cp -a var/lib/tftpboot/* %buildroot/var/lib/tftpboot 

install -D -d -m 755 -o asterisk -g asterisk %buildroot/var/www/pearlpbx 
cp -a web/* %buildroot/var/www/pearlpbx/ 
install -D -m 644 -o root -g root var/lib/pgsql/data/pg_hba.conf %buildroot/var/lib/pgsql/data/pg_hba.conf 

%pre

%post

chkconfig pearlpbx-parsequeuelogd on
chkconfig pearlpbx-hangupd on 
chkconfig asterisk on 
chkconfig postgresql on 
chkconfig httpd on 
chkconfig monit on 

/usr/sbin/PearlPBX-gui-passwd.pl admin admin 

/etc/init.d/postgresql initdb
/etc/init.d/postgresql start 
psql -U postgres -f sql/create_user_asterisk.sql
psql -U asterisk -f sql/asterisk.sql 
psql -U asterisk -f sql/directions_list.sql
psql -U asterisk -f sql/directions.sql 
psql -U asterisk -f sql/sip_conf.sql 
psql -U asterisk -f sql/extensions_conf.sql 
psql -U asterisk -f sql/route.sql 


%files

%changelog
* Wed Feb 27 2013 Alex Radetsky <rad@rad.kiev.ua> 1.0-centos6
- Initial build of Pearl-PBX 1.0 




