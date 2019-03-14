FROM alpine:3.7
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
RUN apk add --no-cache dnsmasq
ENTRYPOINT ["/usr/sbin/dnsmasq","-C","/root/dnsmasq.conf","--no-daemon"] 
