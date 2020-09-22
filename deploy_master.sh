#!/bin/bash

create_docker_compose_conpot() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
    conpot:
        image: stingar/conpot:${VERSION}
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

create_sysconfig_conpot() {
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

create_docker_compose_cowrie() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
  cowrie:
    image: stingar/cowrie:${VERSION}
    restart: always
    volumes:
      - configs:/etc/cowrie
    ports:
      - "2222:2222"
      - "23:2223"
    env_file:
      - cowrie.env
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig_cowrie() {
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
COWRIE_JSON=/etc/cowrie/cowrie.json

# SSH Listen Port
# Can be set to 22 for deployments on real servers
# or left at 2222 and have the port mapped if deployed
# in a container
SSH_LISTEN_PORT=2222

# Telnet Listen Port
# Can be set to 23 for deployments on real servers
# or left at 2223 and have the port mapped if deployed
# in a container
TELNET_LISTEN_PORT=2223

# double quotes, comma delimited tags may be specified, which will be included
# as a field in the hpfeeds output. Use cases include tagging provider
# infrastructure the sensor lives in, geographic location for the sensor, etc.
TAGS=${TAGS}

# A specific "personality" directory for the Cowrie honeypot may be specified
# here. These directories can include custom fs.pickle, cowrie.cfg, txtcmds and
# userdb.txt files which can influence the attractiveness of the honeypot.
PERSONALITY=default
EOF
  echo "Done creating ${APP}.env file!"
}

create_docker_compose_dionaea() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
  dionaea:
    image: stingar/dionaea:${VERSION}
    restart: always
    volumes:
      - configs:/etc/dionaea/
    ports:
      - "21:21"
      - "23:23"
      - "69:69"
      - "123:123"
      - "135:135"
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
    env_file:
      - dionaea.env
    cap_add:
      - NET_ADMIN
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig_dionaea() {
  echo "Creating ${APP}.env..."
  cat <<EOF >${APP}.env
# This can be modified to change the default setup of the dionaea unattended installation

DEBUG=false

# IP Address of the honeypot
# Leaving this blank will default to the docker container IP
IP_ADDRESS=

CHN_SERVER=${URL}
DEPLOY_KEY=${DEPLOY}

# Network options
LISTEN_ADDRESSES=0.0.0.0
LISTEN_INTERFACES=eth0


# Service options
# blackhole, epmap, ftp, http, memcache, mirror, mongo, mqtt, mssql, mysql, pptp, sip, smb, tftp, upnp
SERVICES=(blackhole epmap ftp http memcache mirror mongo mqtt pptp sip smb tftp upnp)

DIONAEA_JSON=/etc/dionaea/dionaea.json

# Logging options
HPFEEDS_ENABLED=true
FEEDS_SERVER=${SERVER}
FEEDS_SERVER_PORT=10000

# Comma separated tags for honeypot
TAGS=${TAGS}

# A specific "personality" directory for the dionaea honeypot may be specified
# here. These directories can include custom dionaea.cfg and service configurations
# files which can influence the attractiveness of the honeypot.
PERSONALITY=
EOF
  echo "Done creating ${APP}.env file!"
}

create_docker_compose_elasticpot() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
  elasticpot:
    image: stingar/elasticpot:${VERSION}
    restart: always
    volumes:
      - configs:/etc/elasticpot
    ports:
      - "9200:9200"
    env_file:
      - elasticpot.env
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig_elasticpot() {
  echo "Creating ${APP}.env..."
  cat <<EOF >${APP}.env
# This can be modified to change the default setup of the elasticpot unattended installation

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
ELASTICPOT_JSON=/etc/elasticpot/elasticpot.json

# double quotes, comma delimited tags may be specified, which will be included
# as a field in the hpfeeds output. Use cases include tagging provider
# infrastructure the sensor lives in, geographic location for the sensor, etc.
TAGS=${TAGS}
EOF
  echo "Done creating ${APP}.env file!"
}

create_docker_compose_rdphoney() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
    rdphoney:
        image: stingar/rdphoney:${VERSION}
        restart: always
        volumes:
            - configs:/etc/rdphoney
        ports:
            - "3389:3389"
        env_file:
            - rdphoney.env
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig_rdphoney() {
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
RDPHONEY_JSON=/etc/rdphoney/rdphoney.json

# Comma separated tags for honeypot
TAGS=${TAGS}
EOF
  echo "Done creating ${APP}.env file!"
}

create_docker_compose_uhp_smtp() {
  echo 'Creating docker-compose.yml...'
  cat <<EOF >./docker-compose.yml
version: '3'
services:
    uhp:
        image: stingar/uhp:${VERSION}
        restart: always
        volumes:
            - configs:/etc/uhp
        ports:
            - "25:2525"
        env_file:
            - ${APP}.env
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig_uhp_smtp() {
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
UHP_JSON=/etc/uhp/uhp.json

# Defaults include auto-config-gen.json, avtech-devices.json, generic-listener.json,
# hajime.json, http-log-headers.json, http.json, pop3.json, and smtp.json
UHP_CONFIG=smtp.json

UHP_LISTEN_PORT=2525

# Comma separated tags for honeypot
TAGS=${TAGS}
EOF
  echo "Done creating ${APP}.env file!"
}

create_docker_compose_big-hp() {
  echo 'Creating docker-compose.yml...'
  cat << EOF > ./docker-compose.yml
version: '3'
services:
  elasticpot:
    image: stingar/big-hp{ARCH}:${VERSION}
    restart: always
    volumes:
      - configs:/etc/big-hp
    ports:
      - "443:8000"
    env_file:
      - big-hp.env
volumes:
    configs:
EOF
  echo 'Done creating docker-compose.yml!'
}

create_sysconfig_big-hp() {
  echo "Creating ${APP}.env..."
  cat <<EOF >${APP}.env

  # This can be modified to change the default setup of the elasticpot unattended installation

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
  BIGHP_JSON=/etc/big-hp/big-hp.json

  # double quotes, comma delimited tags may be specified, which will be included
  # as a field in the hpfeeds output. Use cases include tagging provider
  # infrastructure the sensor lives in, geographic location for the sensor, etc.
  TAGS=${TAGS}
EOF
  echo "Done creating ${APP}.env file!"
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
        AUTOTAGS="asn:${ASN}"
      fi
      PREFIX=$(echo ${ALL} | awk -F'|' '{print $2}' | sed -e 's/[ \t]*//g')
      if [[ -n ${PREFIX} ]]; then
        AUTOTAGS="$AUTOTAGS,prefix:${PREFIX}"
      fi
    fi
  fi

}

#################### Start Executing ########################


URL=$1
DEPLOY=$2
SERVER=$(echo ${URL} | awk -F/ '{print $3}')
VERSION=master
APP=$3

INSTALL_DIR="./${APP}"
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

create_docker_compose_${APP}
create_sysconfig_${APP}
echo ''
echo 'Type "docker-compose ps" to confirm your honeypot is running'
echo 'You may type "docker-compose logs" to get any error or informational logs from your honeypot'
