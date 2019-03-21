#!/bin/sh

ip tuntap add mode tap tap0

ip link set tap0 master br0

ip link set dev br0 up

ip link set dev tap0 up

/usr/bin/qemu-system-x86_64 -nographic -serial mon:stdio  -device virtio-net,netdev=network0,mac=52:55:00:d1:55:01 -netdev tap,id=network0,ifname=tap0,script=no,downscript=no -m 512 -smp 1 -machine type=pc,accel=kvm -drive file=/root/vyos.img,if=virtio,cache=writeback,discard=ignore,format=qcow2 -boot once=d

# text console using 