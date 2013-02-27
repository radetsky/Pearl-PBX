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
Web GUI for Asterisk written by Alex Radetsky <rad@rad.kiev.ua>

%prep
%setup -n %name-%version

%build

%install

%pre

%files

%changelog
* Wed Feb 27 2013 Alex Radetsky <rad@rad.kiev.ua> 1.0-centos6
- Initial build of Pearl-PBX 1.0 




