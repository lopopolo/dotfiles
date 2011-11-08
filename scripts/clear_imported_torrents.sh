#!/usr/bin/env sh

cd /Users/lopopolo/Downloads

shopt -s nullglob
found=0
for i in *.torrent.imported; do
  found=1
done
shopt -u nullglob

[ $found -eq 1 ] && rm *.torrent.imported

