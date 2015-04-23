#!/bin/bash
#
# Для того, что бы корректно перенести PearlPBX из точки А в точку Б, надо еще сделать следующие действия:
# 1. Создать в точке Б соответствующее количество интерфейсов 
# 2. Прописать в них адреса из точки А в опущенном состоянии на всех интерфейсах, кроме основного
# 3. Прописать роутинг в файлах ifcfg-route 
# 4. Прописать файрволл изменив правила или адреса.  
# 5. Прописать в основном интерфейсе правильный адрес после перезапуска  
# 6. Сохранить запасной адрес основного интерфейса в качестве алиаса 
# 7. Опустить все на точке А, установив там временный адрес №2
# 8. Сделать backup.sh 
# 9. Скопировать backup-pearlpbx-YYYYMMDD_HHMMSS.tar.gz 
# 10. Сделать restore.sh backup-pearlpbx-YYYYMMDD_HHMMSS.tar.gz 
# 11. /etc/init.d/PearlPBX start 
# 12. Проверить и ребутнуть систему. 

# Итого требования: 
# 1. Два временных адреса 
# 2. Удаленный доступ на обе машины одновременно 

mkdir backup-pearlpbx 
cd backup-pearlpbx
pg_dump -U asterisk >./asterisk.sql 
mkdir -p etc/asterisk
cp -a /etc/asterisk/* etc/asterisk/
mkdir sounds
mkdir moh 
cp -a /usr/share/asterisk/sounds/ru/pearlpbx/* ./sounds
cp -a /usr/share/asterisk/moh/* ./moh 
mkdir PearlPBX
cp -a /etc/PearlPBX/* ./PearlPBX
DATE=`date +%Y-%m-%d_%H%M%S`
cd ..
tar zcvf backup-pearlpbx-$DATE.tar.gz ./backup-pearlpbx  


