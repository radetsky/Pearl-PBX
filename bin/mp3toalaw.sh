#!/bin/bash

for file in $(find . -name '*.mp3')
do
    echo $file
    sox $file -t al -c 1 -r 8000 $(echo "$file" | sed -r 's|.mp3|.alaw|g')
done

