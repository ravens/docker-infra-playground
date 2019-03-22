FROM alpine:3.7
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
RUN apk add --no-cache qemu-system-x86_64 libvirt qemu-img bridge iproute2
WORKDIR /root
COPY build/vyos.img /root/vyos.img
COPY run.sh /root/run.sh
ENTRYPOINT ["/bin/sh","/root/run.sh"]
