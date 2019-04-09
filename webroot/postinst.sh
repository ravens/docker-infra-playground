#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# saltstack install
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub |  apt-key add -
echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list
sudo apt-get -qy update
mkdir /etc/salt
echo "master: 192.168.25.5" >  /etc/salt/minion
hostname > /etc/salt/minion_id
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy install  salt-minion
