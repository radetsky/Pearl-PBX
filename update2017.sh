#!/bin/bash

cp lib/PearlPBX/App.pm /usr/share/perl5/PearlPBX/
cp lib/PearlPBX/Logger.pm /usr/share/perl5/PearlPBX/
yum install perl-Clone
cp /usr/sbin/NetSDS-hangupd.pl /usr/sbin/NetSDS-hangupd.orig.pl
cp sbin/NetSDS-hangupd.pl /usr/sbin/
systemctl restart pearlpbxd


