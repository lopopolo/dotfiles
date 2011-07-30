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

