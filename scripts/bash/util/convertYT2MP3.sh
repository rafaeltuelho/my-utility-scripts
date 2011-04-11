#!/bin/sh

yt-mp3chanrip() { 
for count in 1 51 101 151 201 251 301; do for i in $(curl -s http://gdata.youtube.com/feeds/api/users/"$1"/uploads\?start-index="$count"\&max-results=50 | grep -Eo "watch\?v=[^[:space:]\"\'\\]{11}" | uniq); do ffmpeg -i $(wget http://youtube.com/"$i" -qO- | sed -n "/fmt_url_map/{s/[\'\"\|]/\n/g;p}" | sed -n '/^fmt_url_map/,/videoplayback/p' | sed -e :a -e '$q;N;5,$D;ba' | tr -d '\n' | sed -e 's/\(.*\),\(.\)\{1,3\}/\1/') -vn -ab 128k "$(youtube-dl -e http://youtube.com/"$i").mp3"; done; done; unset count i; 
}
