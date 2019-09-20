#!/bin/sh


wget -O /tmp/ubuntu.qcow2 https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
docker run -v /tmp:/tmp --device /dev/sda anishs/qemu-img convert /tmp/ubuntu.qcow2 -O raw /dev/sda
reboot
