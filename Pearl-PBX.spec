Name: Pearl-PBX
Version: 1.1
Release: centos6

Summary: Contact-center for SMB written by Alex Radetsky <rad@rad.kiev.ua> 

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
Requires: asterisk-voicemail-plain 
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
Requires: pwgen 
Requires: perl-File-Tail 
Requires: rpmforge-release
Requires: epel-release

%description
Web GUI for Asterisk written by Alex Radetsky <rad@rad.kiev.ua>

%prep
%setup -n %name-%version

%build

%install

rm -rf %{buildroot}

mkdir -p %buildroot/var/run/NetSDS
chmod 777 %buildroot/var/run/NetSDS

mkdir -p %buildroot/usr/share/asterisk/agi-bin
install -m 755  agi-bin/NetSDS-AGI-integration.pl %buildroot/usr/share/asterisk/agi-bin
install -m 755  agi-bin/NetSDS-route.pl %buildroot/usr/share/asterisk/agi-bin
install -m 755  agi-bin/PearlPBX* %buildroot/usr/share/asterisk/agi-bin 

mkdir -p %buildroot/usr/bin
mkdir -p %buildroot/usr/sbin
install -D -m 755  bin/* %buildroot/usr/bin/ 
install -D -m 755  sbin/* %buildroot/usr/sbin/

install -d -m 755  %buildroot/etc/NetSDS
install -m 644  etc/NetSDS/asterisk-router.conf %buildroot/etc/NetSDS

install -D -m 644  etc/apache2/sites-available/pearlpbx %buildroot/etc/httpd/conf.d/pearlpbx.conf 

install -d -m 755 %buildroot/etc/monit.d
install -d -m 755 %{buildroot}%{_initrddir} 
install -D -m 755  etc/init.d/pearlpbx-parsequeuelogd %{buildroot}%{_initrddir}/ 
install -D -m 644  etc/monit.d/* %buildroot/etc/monit.d/

install -D -m 755  etc/init.d/pearlpbx-hangupd %{buildroot}%{_initrddir}/
install -D -m 755  etc/monit.d/pearlpbx-hangupd %buildroot/etc/monit.d/

install -D -m 755  etc/monit.d/asterisk %buildroot/etc/monit.d/

install -d -m 755  %buildroot/etc/cron.d
install -D -m 644  etc/cron.d/* %buildroot/etc/cron.d/ 

install -d -m 755  %buildroot/etc/NetSDS/asterisk
install -D -m 755  etc/asterisk1.8/* %buildroot/etc/NetSDS/asterisk/

install -d -m 755 %buildroot/etc/NetSDS/sql
install -D -m 644 sql/* %buildroot/etc/NetSDS/sql/

install -d -m 755  %buildroot/usr/share/perl5
install -D -m 644  lib/*.pm %buildroot/usr/share/perl5/

cp -a lib/PearlPBX %buildroot/usr/share/perl5
cp -a lib/Pearl %buildroot/usr/share/perl5
cp -a lib/NetSDS %buildroot/usr/share/perl5

mkdir -p %buildroot/usr/share/pearlpbx
cp -av share/reports %buildroot/usr/share/pearlpbx/
cp -av share/provision %buildroot/usr/share/pearlpbx/ 
cp -av share/modules %buildroot/usr/share/pearlpbx/


install -d -m 755  %buildroot/usr/share/asterisk/sounds
cp -av sounds/* %buildroot/usr/share/asterisk/sounds/ 

mkdir -p %buildroot/var/lib/tftpboot
chmod 777 %buildroot/var/lib/tftpboot
cp -a var/lib/tftpboot/* %buildroot/var/lib/tftpboot 

install -D -d -m 755  %buildroot/var/www/pearlpbx 
cp -a web/* %buildroot/var/www/pearlpbx/ 
install -D -m 644 var/lib/pgsql/data/pg_hba.conf %buildroot/var/tmp/pg_hba.conf 

%pre

%post

ln -sf /etc/NetSDS /etc/PearlPBX

chkconfig pearlpbx-parsequeuelogd on
chkconfig pearlpbx-hangupd on 
chkconfig asterisk on 
chkconfig postgresql on 
chkconfig httpd on 
chkconfig monit on 

/etc/init.d/postgresql initdb
mv /var/tmp/pg_hba.conf /var/lib/pgsql/data/
/etc/init.d/postgresql start 

psql -U postgres -f /etc/NetSDS/sql/create_user_asterisk.sql
psql -U postgres -f /etc/NetSDS/sql/asterisk.sql 
psql -U asterisk -f /etc/NetSDS/sql/directions_list.sql
psql -U asterisk -f /etc/NetSDS/sql/directions.sql 
psql -U asterisk -f /etc/NetSDS/sql/sip_conf.sql 
psql -U asterisk -f /etc/NetSDS/sql/extensions_conf.sql 
psql -U asterisk -f /etc/NetSDS/sql/route.sql
psql -U asterisk -f /etc/NetSDS/sql/cal.sql 
psql -U asterisk -f /etc/NetSDS/sql/ivr.sql 


mv -f /etc/PearlPBX/asterisk/* /etc/asterisk/ 

/usr/sbin/PearlPBX-gui-passwd.pl admin admin 
/usr/bin/ulines.pl


%files
%defattr(-,root,root,-)
%doc README* *.txt LICENSE  

%{_initrddir}/pearlpbx-parsequeuelogd
%{_initrddir}/pearlpbx-hangupd
%config /etc/NetSDS/asterisk/* 
%config /etc/NetSDS/sql/*
%config(noreplace) /etc/NetSDS/asterisk-router.conf
%config /etc/cron.d/pearlpbx
%config /etc/httpd/conf.d/pearlpbx.conf
%config /etc/monit.d/asterisk
%config /etc/monit.d/pearlpbx-hangupd
%config /etc/monit.d/pearlpbx-parsequeuelogd
/usr/bin/PearlPBX-tftpprovisor.pl
/usr/bin/ffmpeg-any-to-alaw.sh
/usr/bin/grandstream-config.pl
/usr/bin/gspeech.sh
/usr/bin/moh-convert.pl
/usr/bin/permissions.pl
/usr/bin/tftpprovisor.sh
/usr/bin/ulines.pl
/usr/sbin/NetSDS-hangupd.pl
/usr/sbin/NetSDS-parsequeuelogd.pl
/usr/sbin/PearlPBX-gui-passwd.pl
/usr/sbin/PearlPBX-parsequeuelogd.pl
/usr/sbin/PearlPBX-recd.pl
/usr/sbin/missedcallnotification.pl
/usr/sbin/removedublicatefromqueuelog.pl
/usr/share/asterisk/sounds/en/pearlpbx-nomorelines.alaw
/usr/share/asterisk/sounds/en/pearlpbx-nomorelines.mp3
/usr/share/asterisk/sounds/en/pearlpbx-nomorelines.wav
/usr/share/asterisk/sounds/ru/pearlpbx-nomorelines.alaw
/usr/share/asterisk/sounds/ru/pearlpbx-nomorelines.mp3
/usr/share/asterisk/sounds/ru/pearlpbx-nomorelines.wav
/usr/share/pearlpbx/reports/001-alltraffic.html
/usr/share/pearlpbx/reports/002-calls-to-external-extension.html
/usr/share/pearlpbx/reports/003-incoming-from-customer.html
/usr/share/pearlpbx/reports/004-outgoing-to-customer.html
/usr/share/pearlpbx/reports/005-outgoing-made-by-group.html
/usr/share/pearlpbx/reports/006-incoming-to-group.html
/usr/share/pearlpbx/reports/007-outgoing-made-by-operator.html
/usr/share/pearlpbx/reports/008-incoming-to-operator.html
/usr/share/pearlpbx/reports/009-customer.html
/usr/share/pearlpbx/reports/README
/usr/share/pearlpbx/reports/summary/010-sum-calls-to-external-extensions.html
/usr/share/pearlpbx/reports/summary/020-sum-calls-to-groups.html
/usr/share/pearlpbx/reports/summary/030-received-by-operators-in-groups.html
/usr/share/pearlpbx/reports/summary/035-received-by-operators.html
/usr/share/pearlpbx/reports/summary/040-outgoing-by-operators-in-group.html
/usr/share/pearlpbx/reports/summary/045-lost-in-groups.html
/usr/share/pearlpbx/reports/templates/ExternalNumbers.html
/usr/share/pearlpbx/reports/templates/ListChannels.html
/usr/share/pearlpbx/reports/templates/ListQueues.html
/usr/share/pearlpbx/reports/templates/LostInGroups.html
/usr/share/pearlpbx/reports/templates/Makefile
/usr/share/pearlpbx/reports/templates/Recordings.html
/usr/share/pearlpbx/reports/templates/SumCallsToExternalExtensions.html
/usr/share/pearlpbx/reports/templates/SumCallsToGroups.html
/usr/share/pearlpbx/reports/templates/SumOutgoingByOperatorsInGroup.html
/usr/share/pearlpbx/reports/templates/SumReceivedByOperators.html
/usr/share/pearlpbx/reports/templates/SumReceivedByOperatorsInGroup.html
/usr/share/pearlpbx/reports/templates/alltraffic.html
/usr/share/pearlpbx/reports/templates/callsToExternalNumbers.html
/usr/share/pearlpbx/reports/templates/cdrfilter.html
/usr/share/pearlpbx/reports/templates/customer.html
/usr/share/pearlpbx/reports/templates/incomingFromCustomer.html
/usr/share/pearlpbx/reports/templates/incomingToGroup.html
/usr/share/pearlpbx/reports/templates/incomingToOperator.html
/usr/share/pearlpbx/reports/templates/outgoingMadeByGroup.html
/usr/share/pearlpbx/reports/templates/outgoingMadeByOperator.html
/usr/share/pearlpbx/reports/templates/outgoingToCustomer.html
/usr/share/perl5/NetSDS/Util/DateTime.pm
/usr/share/perl5/NetSDS/Util/String.pm
/usr/share/perl5/Pearl.pm
/usr/share/perl5/Pearl/Auth.pm
/usr/share/perl5/Pearl/Session.pm
/usr/share/perl5/PearlPBX/Queues.pm
/usr/share/perl5/PearlPBX/Report.pm
/usr/share/perl5/PearlPBX/Report/ExternalNumbers.pm
/usr/share/perl5/PearlPBX/Report/ListChannels.pm
/usr/share/perl5/PearlPBX/Report/ListQueues.pm
/usr/share/perl5/PearlPBX/Report/LostInGroups.pm
/usr/share/perl5/PearlPBX/Report/Recordings.pm
/usr/share/perl5/PearlPBX/Report/SumCallsToExternalExtensions.pm
/usr/share/perl5/PearlPBX/Report/SumCallsToGroups.pm
/usr/share/perl5/PearlPBX/Report/SumOutgoingByOperatorsInGroup.pm
/usr/share/perl5/PearlPBX/Report/SumReceivedByOperators.pm
/usr/share/perl5/PearlPBX/Report/SumReceivedByOperatorsInGroup.pm
/usr/share/perl5/PearlPBX/Report/alltraffic.pm
/usr/share/perl5/PearlPBX/Report/callsToExternalNumbers.pm
/usr/share/perl5/PearlPBX/Report/cdrfilter.pm
/usr/share/perl5/PearlPBX/Report/customer.pm
/usr/share/perl5/PearlPBX/Report/incomingFromCustomer.pm
/usr/share/perl5/PearlPBX/Report/incomingToGroup.pm
/usr/share/perl5/PearlPBX/Report/incomingToOperator.pm
/usr/share/perl5/PearlPBX/Report/listlostcalls.pm
/usr/share/perl5/PearlPBX/Report/outgoingMadeByGroup.pm
/usr/share/perl5/PearlPBX/Report/outgoingMadeByOperator.pm
/usr/share/perl5/PearlPBX/Report/outgoingToCustomer.pm
/usr/share/perl5/PearlPBX/Route.pm
/usr/share/perl5/PearlPBX/SIP.pm
/usr/share/asterisk/agi-bin/NetSDS-AGI-integration.pl
/usr/share/asterisk/agi-bin/NetSDS-route.pl
/var/tmp/pg_hba.conf
/var/lib/tftpboot/lang/spa502g_en.xml
/var/lib/tftpboot/lang/spa502g_ru.xml
/var/lib/tftpboot/spa502G.cfg
/var/lib/tftpboot/spa502G.xml
/var/lib/tftpboot/spa504G.cfg
/var/lib/tftpboot/spa504G.xml
/var/www/pearlpbx/cdr2recordings.pl
/var/www/pearlpbx/css/.DS_Store
/var/www/pearlpbx/css/bootstrap-datepicker.css
/var/www/pearlpbx/css/bootstrap-responsive.css
/var/www/pearlpbx/css/bootstrap-responsive.min.css
/var/www/pearlpbx/css/bootstrap.css
/var/www/pearlpbx/css/bootstrap.min.css
/var/www/pearlpbx/css/pearlpbx.css
/var/www/pearlpbx/img/.DS_Store
/var/www/pearlpbx/img/PearlPBX-logo-icon.gif
/var/www/pearlpbx/img/PearlPBX-logo-icon.ico
/var/www/pearlpbx/img/PearlPBX-logo.PSD
/var/www/pearlpbx/img/PearlPBX-logo.png
/var/www/pearlpbx/img/glyphicons-halflings-white.png
/var/www/pearlpbx/img/glyphicons-halflings.png
/var/www/pearlpbx/img/remove-icon.png
/var/www/pearlpbx/index.html
/var/www/pearlpbx/jPlayer/Jplayer.swf
/var/www/pearlpbx/jPlayer/add-on/jplayer.playlist.min.js
/var/www/pearlpbx/jPlayer/add-on/jquery.jplayer.inspector.js
/var/www/pearlpbx/jPlayer/jquery.jplayer.min.js
/var/www/pearlpbx/jPlayer/skin/blue.monday/jplayer.blue.monday.css
/var/www/pearlpbx/jPlayer/skin/blue.monday/jplayer.blue.monday.jpg
/var/www/pearlpbx/jPlayer/skin/blue.monday/jplayer.blue.monday.seeking.gif
/var/www/pearlpbx/jPlayer/skin/blue.monday/jplayer.blue.monday.video.play.png
/var/www/pearlpbx/jPlayer/skin/pink.flag/jplayer.pink.flag.css
/var/www/pearlpbx/jPlayer/skin/pink.flag/jplayer.pink.flag.jpg
/var/www/pearlpbx/jPlayer/skin/pink.flag/jplayer.pink.flag.seeking.gif
/var/www/pearlpbx/jPlayer/skin/pink.flag/jplayer.pink.flag.video.play.png
/var/www/pearlpbx/js/.DS_Store
/var/www/pearlpbx/js/Makefile
/var/www/pearlpbx/js/astman-jah.js
/var/www/pearlpbx/js/bootstrap-datepicker.js
/var/www/pearlpbx/js/bootstrap.js
/var/www/pearlpbx/js/bootstrap.min.js
/var/www/pearlpbx/js/jqPlot/excanvas.js
/var/www/pearlpbx/js/jqPlot/excanvas.min.js
/var/www/pearlpbx/js/jqPlot/jquery.jqplot.css
/var/www/pearlpbx/js/jqPlot/jquery.jqplot.js
/var/www/pearlpbx/js/jqPlot/jquery.jqplot.min.css
/var/www/pearlpbx/js/jqPlot/jquery.jqplot.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.BezierCurveRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.BezierCurveRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.barRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.barRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.blockRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.blockRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.bubbleRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.bubbleRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasAxisLabelRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasAxisLabelRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasAxisTickRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasAxisTickRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasOverlay.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasOverlay.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasTextRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.canvasTextRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.categoryAxisRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.categoryAxisRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.ciParser.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.ciParser.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.cursor.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.cursor.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.dateAxisRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.dateAxisRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.donutRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.donutRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.dragable.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.dragable.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.enhancedLegendRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.enhancedLegendRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.funnelRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.funnelRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.highlighter.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.highlighter.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.json2.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.json2.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.logAxisRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.logAxisRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.mekkoAxisRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.mekkoAxisRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.mekkoRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.mekkoRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.meterGaugeRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.meterGaugeRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.ohlcRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.ohlcRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pieRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pieRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pointLabels.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pointLabels.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pyramidAxisRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pyramidAxisRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pyramidGridRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pyramidGridRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pyramidRenderer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.pyramidRenderer.min.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.trendline.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.trendline.min.js
/var/www/pearlpbx/js/jquery.js
/var/www/pearlpbx/js/pearlpbx.js
/var/www/pearlpbx/login.html
/var/www/pearlpbx/login.pl
/var/www/pearlpbx/queues.pl
/var/www/pearlpbx/recordings.pl
/var/www/pearlpbx/reports.pl
/var/www/pearlpbx/route.pl
/var/www/pearlpbx/sip.pl
/var/www/pearlpbx/stored_sessions.pl
/usr/share/asterisk/sounds/ru/calendar_vacation.mp3
/usr/share/asterisk/sounds/ru/calendar_vacation.ul
/usr/share/asterisk/sounds/ru/calendar_workday.mp3
/usr/share/asterisk/sounds/ru/calendar_workday.ul
/usr/share/asterisk/sounds/ru/checking_addressbook.ul
/usr/share/asterisk/sounds/ru/checking_adressbook.mp3
/usr/share/asterisk/sounds/ru/checking_advfilter.mp3
/usr/share/asterisk/sounds/ru/checking_advfilter.ul
/usr/share/asterisk/sounds/ru/checking_blacklist.mp3
/usr/share/asterisk/sounds/ru/checking_blacklist.ul
/usr/share/asterisk/sounds/ru/checking_calendar.mp3
/usr/share/asterisk/sounds/ru/checking_calendar.ul
/usr/share/asterisk/sounds/ru/checking_hint.mp3
/usr/share/asterisk/sounds/ru/checking_hint.ul
/usr/share/asterisk/sounds/ru/checking_language.mp3
/usr/share/asterisk/sounds/ru/checking_language.ul
/usr/share/asterisk/sounds/ru/checking_personal_operator.mp3
/usr/share/asterisk/sounds/ru/checking_personal_operator.ul
/usr/share/asterisk/sounds/ru/checking_whitelist.mp3
/usr/share/asterisk/sounds/ru/checking_whitelist.ul
/usr/share/asterisk/sounds/ru/privet.mp3
/usr/share/asterisk/sounds/ru/privet.ul
/usr/share/asterisk/sounds/ru/ru_choice_language.mp3
/usr/share/asterisk/sounds/ru/ru_choice_language.ul
/usr/share/asterisk/sounds/ru/ru_selected_language.mp3
/usr/share/asterisk/sounds/ru/ru_selected_language.ul
/usr/share/asterisk/sounds/ru/ua_choice_language.mp3
/usr/share/asterisk/sounds/ru/ua_choice_language.ul
/usr/share/asterisk/sounds/ru/ua_selected_language.mp3
/usr/share/asterisk/sounds/ru/ua_selected_language.ul
/usr/share/perl5/PearlPBX/Audiofile.pm
/usr/share/perl5/PearlPBX/IVR.pm
/usr/share/perl5/PearlPBX/Module.pm
/usr/share/perl5/PearlPBX/Module/Audiofiles.pm
/usr/share/perl5/PearlPBX/Module/Calendar.pm
/usr/share/perl5/PearlPBX/Module/Hints.pm
/usr/share/perl5/PearlPBX/Module/IVREdit.pm
/usr/share/perl5/PearlPBX/Module/WBList.pm
/var/www/pearlpbx/img/PearlPBX-logo-big.png
/var/www/pearlpbx/img/PearlPBX-logo-mid.PNG
/var/www/pearlpbx/img/PearlPBX-logo-text.PNG
/var/www/pearlpbx/img/PearlPBX-logo-text.PSD
/var/www/pearlpbx/integration_webcrm.html
/var/www/pearlpbx/jPlayer/extras/jquery-1.8.2-ajax-deprecated.min.js
/var/www/pearlpbx/jPlayer/extras/jquery.jplayer.combo.min.js
/var/www/pearlpbx/jPlayer/extras/jquery.jplayer.playlist.combo.min.js
/var/www/pearlpbx/jPlayer/extras/readme.txt
/var/www/pearlpbx/jPlayer/popcorn/popcorn.jplayer.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.mobile.js
/var/www/pearlpbx/js/jqPlot/plugins/jqplot.mobile.min.js
/var/www/pearlpbx/js/jquery-1.9.1.js
/var/www/pearlpbx/js/jquery-1.9.1.min.js
/var/www/pearlpbx/js/jquery.form.js
/var/www/pearlpbx/js/jquery.ui.widget.js
/var/www/pearlpbx/modules.pl
/var/www/pearlpbx/uploader.pl
/usr/share/pearlpbx/modules/ivr/000-ivr-gui.html
/usr/share/pearlpbx/modules/ivr/001-ivr-calendar.html
/usr/share/pearlpbx/modules/ivr/002-ivr-voicefiles.html
/usr/share/pearlpbx/modules/ivr/003-ivr-blacklist.html
/usr/share/pearlpbx/modules/ivr/004-ivr-whitelist.html
/usr/share/pearlpbx/modules/ivr/005-ivr-addressbook.html
/usr/share/pearlpbx/modules/ivr/006-ivr-advfilter.html
/usr/share/pearlpbx/modules/ivr/007-ivr-hint.html
/usr/share/pearlpbx/modules/ivr/008-ivr-language.html
/usr/share/pearlpbx/modules/ivr/009-ivr-poperator.html
/usr/share/pearlpbx/modules/ivr/010-musiconhold.html
/usr/share/pearlpbx/provision/GrandStreamGXP1200.cfg
/usr/share/pearlpbx/provision/SPA502G.cfg
/usr/share/pearlpbx/provision/SPA504G.cfg
/usr/share/asterisk/agi-bin/PearlPBX-addressbook.pl
/usr/share/asterisk/agi-bin/PearlPBX-advfilter.pl
/usr/share/asterisk/agi-bin/PearlPBX-blacklist.pl
/usr/share/asterisk/agi-bin/PearlPBX-calendar.pl
/usr/share/asterisk/agi-bin/PearlPBX-hint.pl
/usr/share/asterisk/agi-bin/PearlPBX-language.pl
/usr/share/asterisk/agi-bin/PearlPBX-poperator.pl
/usr/share/asterisk/agi-bin/PearlPBX-whitelist.pl

%changelog
* Thu Apr 25 2013 Alex Radetsky <rad@rad.kiev.ua> 1.1-centos6
- Many patches, many fixes. 
- Upgrade to PearlPBX 1.1 

* Wed Feb 27 2013 Alex Radetsky <rad@rad.kiev.ua> 1.0-centos6
- Initial build of Pearl-PBX 1.0 




