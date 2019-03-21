FROM alpine:3.7
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
RUN apk add --no-cache qemu-system-x86_64 libvirt qemu-img bridge iproute2
# FROM ubuntu:18.04
# MAINTAINER Yan Grunenberger <yan@grunenberger.net>
# ENV DEBIAN_FRONTEND noninteractive
# RUN apt-get update
# RUN apt install -qy qemu-kvm
WORKDIR /root
COPY build/vyos.img /root/vyos.img
COPY run.sh /root/run.sh
ENTRYPOINT ["/bin/sh","/root/run.sh"]
#ENV PACKER_VERSION 1.3.5
#RUN wget -O /root/packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
#RUN unzip /root/packer_${PACKER_VERSION}_linux_amd64.zip && chmod ugo+x /root/packer && mv /root/packer /usr/local/bin/packer
# https://releases.hashicorp.com/packer/1.3.5/packer_1.3.5_linux_amd64.zip
#/usr/bin/qemu-system-x86_64 -vnc 127.0.0.1:48 -m 512 -netdev user,id=user.0,hostfwd=tcp::2771-:22 -device virtio-net,netdev=user.0 -drive file=build/vyos.img,if=virtio,cache=writeback,discard=ignore,format=qcow2 -name vyos.img -boot once=d -smp 1 -machine type=pc,accel=kvm -cdrom /home/yan/Documents/perso/docker-infra-playground/vyos-nfv/packer_cache/f684e692b2912f2bb544ba6a24a61d123300aebe64e6da7069ab9401bf0807ce.iso