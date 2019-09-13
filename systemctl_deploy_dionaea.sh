#!/bin/bash

create_docker_compose() {
echo 'Creating docker-compose.yml...'
cat << EOF > ./docker-compose.yml
version: '2'
services:
  dionaea:
    image: stingar/dionaea${ARCH}:${VERSION}
    volumes:
      - ./dionaea.sysconfig:/etc/default/dionaea:z
      - ./dionaea/dionaea:/etc/dionaea/:z
    ports:
      - "21:21"
      - "23:23"
      - "69:69"
      - "80:80"
      - "123:123"
      - "135:135"
      - "443:443"
      - "445:445"
      - "1433:1433"
      - "1723:1723"
      - "1883:1883"
      - "1900:1900"
      - "3306:3306"
      - "5000:5000"
      - "5060:5060"
      - "5061:5061"
      - "11211:11211"
      - "27017:27017"
EOF
echo 'Done creating docker-compose.yml!'
}

create_sysconfig () {
echo "Creating ${APP}.sysconfig..."
cat << EOF > ${APP}.sysconfig
# This can be modified to change the default setup of the dionaea unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

CHN_SERVER="${URL}"
DEPLOY_KEY=${DEPLOY}

# Network options
LISTEN_ADDRESSES="0.0.0.0"
LISTEN_INTERFACES="eth0"


# Service options
# blackhole, epmap, ftp, http, memcache, mirror, mongo, mqtt, mssql, mysql, pptp, sip, smb, tftp, upnp
SERVICES=(blackhole epmap ftp http memcache mirror mongo mqtt pptp sip smb tftp upnp)

DIONAEA_JSON="/etc/dionaea/dionaea.json"

# Logging options
HPFEEDS_ENABLED=true
FEEDS_SERVER="${SERVER}"
FEEDS_SERVER_PORT=10000

# Comma separated tags for honeypot
TAGS="${TAGS}"
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
ExecStartPre=${DOCKERCOMPOSE} down -v
ExecStartPre=${DOCKERCOMPOSE} rm -fv
ExecStartPre=${DOCKERCOMPOSE} pull

# Compose up
ExecStart=${DOCKERCOMPOSE} up

# Compose down, remove containers and volumes
ExecStop=${DOCKERCOMPOSE} down -v

[Install]
WantedBy=multi-user.target
EOF
echo "Done creating ${APP}.service file!"
}

create_auto_tags () {
# canhazip.com is run by Cloudflare, as opposed to icanhazip.com, and returns the public IP of the caller
IP=$(curl -s https://canhazip.com)

# We need whois package installed to get detailed IP info
apt-get install -y whois

if [[ -n ${IP} ]]
then
        # Shadowserver.org provides useful security services, such as a enriching an IP with the originating AS and prefix
        ALL=$(whois -h asn.shadowserver.org "origin ${IP}")
        if [[ -n ${ALL} ]]
        then
                ASN=$(echo ${ALL}|awk -F'|' '{print $1}'|sed -e 's/[ \t]*//g')
                if [[ -n ${ASN} ]]
                then
                        AUTOTAGS="asn-${ASN}"
                fi
                PREFIX=$(echo ${ALL}|awk -F'|' '{print $2}'|sed -e 's/[ \t]*//g')
                if [[ -n ${PREFIX} ]]
                then
                        AUTOTAGS="$AUTOTAGS,prefix-${PREFIX}"
                fi
        fi
fi

}

URL=$1
DEPLOY=$2
ARCH=$3
SERVER=$(echo ${URL} | awk -F/ '{print $3}')
VERSION=1.8

APP='dionaea'
INSTALL_DIR="/opt/${APP}"
SYSTEMCTL=$(which systemctl)
DOCKERCOMPOSE=$(which docker-compose)
# Check if DOCKERCOMPOSE is empty, and if so, exit with an error
[ -z ${DOCKERCOMPOSE} ] && echo "Couldn't find docker-compose; bailing!" && exit 1

create_auto_tags

if [[ -n ${TAGS} ]]
then
        TAGS="\"${TAGS},${AUTOTAGS}\""
else
        TAGS="\"${AUTOTAGS}\""
fi

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
