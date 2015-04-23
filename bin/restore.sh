#!/bin/bash

/etc/init.d/monit stop 
/etc/init.d/PearlPBX stop 
/etc/init.d/postgresql start 
tar zxvf $1 
cd backup-pearlpbx
mkdir -p /usr/share/asterisk/sounds/ru/pearlpbx/ 
cp -av ./sounds/* /usr/share/asterisk/sounds/ru/pearlpbx/ 
mkdir -p /usr/share/asterisk/moh/ 
cp -av ./moh/* /usr/share/asterisk/moh/ 
cp -av etc/asterisk/* /etc/asterisk
cp -av etc/PearlPBX/* /etc/PearlPBX
dropdb -U postgres asterisk 
createdb -U postgres -O asterisk asterisk  
psql -U asterisk -f ./asterisk.sql 

