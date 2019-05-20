#!/bin/bash

create_docker_compose() {
echo 'Creating docker-compose.yml...'
cat << EOF > ./docker-compose.yml
version: '2'
services:
    amun:
        image: stingar/amun${ARCH}:1.7
        volumes:
            - ./amun.sysconfig:/etc/default/amun:z
            - ./amun:/etc/amun:z
        ports:
            - "445:445"
            - "3389:3389"
EOF
echo 'Done creating docker-compose.yml!'
}

create_sysconfig () {
echo "Creating ${APP}.sysconfig..."
cat << EOF > ${APP}.sysconfig
# This file is read from /etc/sysconfig/amun or /etc/default/amun
# depending on the base distro
#
# This can be modified to change the default setup of the amun unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# CHN Server api to register to
CHN_SERVER="${URL}"

# Server to stream data to
FEEDS_SERVER="${SERVER}"
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=${DEPLOY}

# Registration information file
# If running in a container, this needs to persist
AMUN_JSON="/etc/amun/amun.json"

# Comma separated tags for honeypot
TAGS=""
EOF
echo "Done creating ${APP}.sysconfig file!"
}

create_systemctl_file () {
echo "Creating systemctl ${APP}.service file"
cat << EOF > /etc/systemd/system/${APP}.service
[Unit]
Description=${APP} service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=${INSTALL_DIR}

# Remove old containers
ExecStartPre=/usr/bin/docker-compose down -v
ExecStartPre=/usr/bin/docker-compose rm -fv

# Compose up
ExecStart=/usr/bin/docker-compose up

# Compose down, remove containers and volumes
ExecStop=/usr/bin/docker-compose down -v

[Install]
WantedBy=multi-user.target
EOF
echo "Done creating ${APP}.service file!"
}

URL=$1
DEPLOY=$2
ARCH=$4
SERVER=$(echo ${URL} | awk -F/ '{print $3}')

APP='amun'
INSTALL_DIR="/opt/${APP}"
SYSTEMCTL=$(which systemctl)


if [ -x ${SYSTEMCTL} ]
then
  mkdir -p ${INSTALL_DIR}
  chown ${SUDO_USER} ${INSTALL_DIR}
  cd ${INSTALL_DIR}
  create_docker_compose
  create_sysconfig
  create_systemctl_file
  ${SYSTEMCTL} enable --now ${APP}
  ${SYSTEMCTL} start ${APP}.service
  chown ${SUDO_USER} ${INSTALL_DIR}/*
  echo ''
  echo ''
  echo "Type \"sudo systemctl status ${APP}.service\" to confirm your honeypot is running"
  echo "You may type \"sudo journalctl -xe --unit=${APP}.service\" to get any error or informational logs from your
  honeypot"
else
  create_docker_compose
  create_sysconfig
  docker-compose up -d
  echo ''
  echo ''
  echo 'Type "docker-compose ps" to confirm your honeypot is running'
  echo 'You may type "docker-compose logs" to get any error or informational logs from your honeypot'
fi

