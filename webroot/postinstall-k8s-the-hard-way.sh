#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# salt minion install
wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub |  apt-key add -
echo "deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest bionic main" | tee /etc/apt/sources.list.d/saltstack.list
apt-get -qy update
mkdir /etc/salt
echo "master: 192.168.25.10" >  /etc/salt/minion
hostname > /etc/salt/minion_id
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy install  salt-minion

