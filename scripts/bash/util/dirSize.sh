#!/bin/sh

echo ">>> lendo $1..."
du -ks $(ls -d /$1/*) | sort -nr | cut -f2 | xargs -d '\n' du -sh 2> /dev/null
