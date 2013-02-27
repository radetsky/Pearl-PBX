
%define streamdir /opt/sms-stream

%define _perl_lib_path %streamdir/lib

Name: sms-stream
Version: 2.0
Release: alt1

Summary: SMS Stream bulk SMS gateway platform

License: GPL

Group: Networking/Other
Url: http://www.netstyle.com.ua/

Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source0: %name-%version.tar

BuildRequires: make

BuildRequires: perl-CGI perl-Class-Accessor-Class perl-Config-General perl-DBI perl-Encode perl-FCGI perl-Unix-Syslog
BuildRequires: perl-NetSDS perl-Class-Accessor-Class perl-Class-Accessor

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
SMS Stream bulk SMS gateway platform

%prep
%setup -n %name-%version

%build

%install
%makeinstall_std

%pre

%files
%streamdir
#%%doc README samples
#%%dir %%attr(0755,root,root)  %%_sysconfdir/NetSDS/admin/mgr
#%%config(noreplace) %%attr(0755,root,root) %%_sysconfdir/rc.d/init.d/kannel.send-*

%changelog
* Tue Jul 17 2012 Michael Bochkaryov <misha@altlinux.ru> 2.0-alt1
- Initial build of SMS Stream 2.0



