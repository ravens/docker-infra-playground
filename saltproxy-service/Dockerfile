FROM ubuntu:18.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qy update
RUN apt-get -qy install curl gnupg
RUN curl -L https://bootstrap.saltstack.com -o install_salt.sh
RUN sh install_salt.sh -P -M
RUN echo "master: 192.168.25.7" >  /etc/salt/proxy
RUN apt-get -qy install python-pip
RUN pip install napalm-vyos
ENTRYPOINT ["/usr/bin/salt-proxy"]
