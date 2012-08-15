#!/bin/sh

ffmpeg -i $1.mp3 -ar 8000 -ac 1 -ab 64 $1.wav -ar 8000 -ac 1 -ab 64 -f alaw $1.alaw -map 0:0 -map 0:0


