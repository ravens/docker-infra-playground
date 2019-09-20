#!/bin/bash

# identify mapping of container interfaces to actual networks
# this is a workaround those bugs in docker :
# https://github.com/moby/moby/issues/25181
# https://github.com/docker/libnetwork/issues/2093


if [ -z ${BMC_IP} ]  
then
echo "Error: you should set the BMC IP variable so that we can attach our internal bridge to the right overlay network"
exit
else
export BMC_INTF=`netstat -ie | grep -B1 ${BMC_IP} | head -n1 | cut -d ":" -f 1 | cut -d " " -f1`
echo "Management interface within container is ${BMC_INTF}"
echo "Configuring management bridge"
INTERFACE=${BMC_INTF}
BRIDGE=br-bmc
ip addr flush dev $INTERFACE
ip link set $INTERFACE promisc on
brctl addbr $BRIDGE
brctl addif $BRIDGE $INTERFACE
brctl setfd $BRIDGE 0
brctl sethello $BRIDGE 1
ip addr add ${BMC_IP}/24 dev $BRIDGE
ip link set $BRIDGE up
fi


infrasim node start

# turn immedialy node off
#ipmitool -H localhost -U admin -P admin chassis power off

# change boot option if needed
#ipmitool -H localhost -U admin -P admin chassis bootdev pxe options=persistent

tail -f /var/log/infrasim/default/*.log
