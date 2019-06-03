#!/usr/bin/env bash

# call this the correct script id + app name, i.e. to remove cowrie when this is script 15:
# wget "https://stingar-chn-01.oit.duke.edu/api/script/?text=true&script_id=15" -O deploy.sh && sudo bash deploy.sh cowrie

export APP=$1

sudo systemctl stop ${APP}.service
sudo systemctl disable ${APP}.service
sudo rm -f /etc/systemd/system/${APP}.service
sudo rm -rf /opt/${APP}
sudo systemctl daemon-reload
sudo systemctl reset-failed
rm ~/deploy.sh
