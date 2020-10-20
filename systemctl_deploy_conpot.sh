#!/bin/bash

create_docker_compose() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
    conpot:
        image: stingar/conpot${ARCH}:${VERSION}
        restart: always
        volumes:
            - configs:/etc/conpot
        ports:
            - "80:8800"
            - "102:10201"
            - "502:5020"
            - "21:2121"
            - "44818:44818"
        env_file:
            - conpot.env
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig() {
  echo "Creating ${APP}.env..."
  cat <<EOF >${APP}.env
# This can be modified to change the default setup of the unattended installation
DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

# CHN Server api to register to
CHN_SERVER=${URL}

# Server to stream data to
FEEDS_SERVER=${SERVER}
FEEDS_SERVER_PORT=10000

# Deploy key from the FEEDS_SERVER administrator
# This is a REQUIRED value
DEPLOY_KEY=${DEPLOY}

# Registration information file
# If running in a container, this needs to persist
CONPOT_JSON=/etc/conpot/conpot.json

# Conpot specific configuration options
CONPOT_TEMPLATE=default

# Comma separated tags for honeypot
TAGS=${TAGS}
EOF
  echo "Done creating ${APP}.env file!"
}

create_systemctl_file() {
  echo "Creating systemctl ${APP}.service file"
  cat <<EOF >/etc/systemd/system/${APP}.service
[Unit]
Description=${APP} service with docker compose
Requires=docker.service
After=docker.service

[Service]
Restart=always

WorkingDirectory=${INSTALL_DIR}

# Remove old containers
ExecStartPre=${DOCKERCOMPOSE} down
ExecStartPre=${DOCKERCOMPOSE} rm
ExecStartPre=${DOCKERCOMPOSE} pull

# Compose up
ExecStart=${DOCKERCOMPOSE} up

# Compose down, remove containers and volumes
ExecStop=${DOCKERCOMPOSE} down

[Install]
WantedBy=multi-user.target
EOF
  echo "Done creating ${APP}.service file!"
}

create_auto_tags() {
  # canhazip.com is run by Cloudflare, as opposed to icanhazip.com, and returns the public IP of the caller
  IP=$(curl -s https://canhazip.com)

  # We need whois package installed to get detailed IP info
  apt-get install --no-install-recommends -y whois

  if [[ -n ${IP} ]]; then
    # Shadowserver.org provides useful security services, such as a enriching an IP with the originating AS and prefix
    ALL=$(whois -h asn.shadowserver.org "origin ${IP}")
    if [[ -n ${ALL} ]]; then
      ASN=$(echo ${ALL} | awk -F'|' '{print $1}' | sed -e 's/[ \t]*//g')
      if [[ -n ${ASN} ]]; then
        AUTOTAGS="asn-${ASN}"
      fi
      PREFIX=$(echo ${ALL} | awk -F'|' '{print $2}' | sed -e 's/[ \t]*//g')
      if [[ -n ${PREFIX} ]]; then
        AUTOTAGS="$AUTOTAGS,prefix-${PREFIX}"
      fi
    fi
  fi

}

URL=$1
DEPLOY=$2
ARCH=$3
SERVER=$(echo ${URL} | awk -F/ '{print $3}')
VERSION=1.9.1

APP='conpot'
INSTALL_DIR="/opt/${APP}"
SYSTEMCTL=$(which systemctl)
DOCKERCOMPOSE=$(which docker-compose)
# Check if DOCKERCOMPOSE is empty, and if so, exit with an error
[ -z ${DOCKERCOMPOSE} ] && echo "Couldn't find docker-compose; bailing!" && exit 1

create_auto_tags

if [[ -n ${TAGS} ]]; then
    TAGS="${TAGS},${AUTOTAGS}"
else
  TAGS="${AUTOTAGS}"
fi

if [ -x ${SYSTEMCTL} ]; then
  mkdir -p ${INSTALL_DIR}
  chown ${SUDO_USER} ${INSTALL_DIR}
  cd ${INSTALL_DIR}
  create_docker_compose
  create_sysconfig
  create_systemctl_file
  ${SYSTEMCTL} enable --now ${APP}

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
