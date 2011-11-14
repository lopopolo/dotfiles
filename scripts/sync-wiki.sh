#!/usr/bin/env sh

cd /home/lopopolo/repos/wiki
sudo -u lopopolo git pull
sudo -u lopopolo git push

chgrp -R web /home/lopopolo/repos/wiki
chmod -R g+w /home/lopopolo/repos/wiki

