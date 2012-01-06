function torrents
{
echo "Enter password for lopopolo@thekremlin.dyndns.org when prompted"
scp ~/Downloads/*.torrent lopopolo@thekremlin.dyndns.org:/Users/lopopolo/Downloads/
if [ $? -eq 0 ]; then
  echo "torrent files successfully copied to thekremlin.dyndns.org"
  echo "moving local torrent files to trash"
  mv ~/Downloads/*.torrent ~/.Trash/
else
  echo "scp failed"
  return 1
fi
}

function freq
{
  cat ~/.*h_h*|cut -d" " -f1|ruby -e'h=Hash.new 0;h[$_]+=1 while gets;h.each{|k,v|puts"#{v} "+k}'|sort -rn|head
}


