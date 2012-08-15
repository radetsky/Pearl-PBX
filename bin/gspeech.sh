#!/bin/sh

wget -U "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5" "http://translate.google.com/translate_tts?q=$1&tl=$2" -O $3 


