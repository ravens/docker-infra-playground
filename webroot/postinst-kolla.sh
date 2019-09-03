#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# to detect from the logs when the nodes are ready to use
wget -O /tmp/ok http://192.168.25.3/ok