#!/bin/sh
DATADIR=/var/spool/asterisk/monitor
RESERVED=50000000
MAXDAYS=7
while [ "$MAXDAYS" -gt "0" ]; do
  UNUSED=`df -k $DATADIR | awk 'NR==2 {print $4}'`
  if [ "$UNUSED" -gt "$RESERVED" ]; then
    break
  fi
  find $DATADIR -mindepth 3 -maxdepth 3 -type d \
    -regextype posix-basic -regex '.*[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | \
    sort | head -n 1 | xargs rm -R
  MAXDAYS=$(( MAXDAYS - 1 ))
done

