#!/bin/bash

'''
owner: alok.shrivastava
id: alok183

'''
#Error handling function
function funErrorExit() {
  echo
  echo "ERROR: $${PROGNAME}: $${1:-"Unknown Error"}" 1>&2
  #Script End time
  scriptEndTime=$(date +%s)
  echo "---------------------------------"
  echo "completed with error"
  echo "script runtime: $((scriptEndTime - scriptStartTime))s "
  echo "---------------------------------"
  #  exit 1
}

add_repo() {

  echo "---------------------------------"
  echo "Running $${FUNCNAME[0]}"
  echo "---------------------------------"
  wget -O - https://repo.saltstack.com/${SALT_REPO}/ubuntu/18.04/amd64/archive/${SALT_ARCH_RELEASE}/SALTSTACK-GPG-KEY.pub | apt-key add -
  cat >/etc/apt/sources.list.d/saltstack.list <<EOF
deb http://repo.saltstack.com/${SALT_REPO}/ubuntu/18.04/amd64/archive/${SALT_ARCH_RELEASE} bionic main
EOF

}

master_conf() {
  echo "Installing salt-master ..."
  mkdir -p  /var/lib/salt/pki/master
  mkdir -p /etc/salt/pki/master
  apt-get update -y
  apt-get install salt-master -y

  mkdir -p /srv/thorium
  cat >/srv/thorium/key_clean.sls <<EOF
statreg:
  status.reg

keydel:
  key.timeout:
    - require:
      - status: statreg
    - delete: 3600
EOF
  cat >/srv/thorium/top.sls <<EOF
base:
  '*':
    - key_clean
EOF

  #reactor configuration for automatic key acceptance
  cat >/etc/salt/master.d/auto-accept.conf <<EOF
open_mode: True
auto_accept: True
EOF

  cat >/etc/salt/master.d/master.conf <<EOF
#thorium configuration for automatic key removal
engines:
  - thorium: {}
EOF
  salt-key -L
  if [[ $? -eq 0 ]]; then
    echo "Salt master setup successful"
  else
    funErrorExit "$${FUNCNAME[0]}: Salt master setup failed"
  fi

  service salt-master restart
}

############### minion ###########
minion_conf() {
  echo "Installing salt-minion ..."
  mkdir -p  /var/lib/salt/pki/minion
  apt-get update -y
  apt-get install salt-minion -y
  cat >/etc/salt/minion.d/primary.conf <<EOF
master: salt-master-service
id: salt-minion-$(hostname)
EOF
  cat >>/etc/salt/minion <<EOF
beacons:
  status:
    - interval: 10
EOF

  service salt-minion restart

}

# sleep 10
add_repo
# Variables from env
echo "Salt Role   :  $SALT_ROLE"
echo "Salt verssion   :  $SALT_ARCH_RELEASE"
echo "SALT_REPO    : $SALT_REPO"
if [ "$SALT_ROLE" = "salt-master" ]; then
  master_conf
fi
if [ "$SALT_ROLE" = "salt-minion" ]; then
  minion_conf
fi
#/usr/sbin/init
tail -f /dev/null