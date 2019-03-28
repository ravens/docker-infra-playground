FROM ubuntu:18.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qy update
RUN apt-get -qy install dmidecode wget gnupg
RUN wget https://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub
RUN apt-key add SALTSTACK-GPG-KEY.pub
RUN echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/latest bionic main> /etc/apt/sources.list.d/salt.list"
RUN apt-get -qy update
RUN apt-get -qy install salt-master salt-api
VOLUME ['/etc/salt/pki', '/var/cache/salt', '/var/logs/salt', '/etc/salt/master.d', '/srv/salt']

RUN apt-get -qy install supervisor
COPY salt-supervisor.conf /root/salt-supervisor.conf
COPY salt-api.conf /etc/salt/master.d/salt-api.conf
EXPOSE 4505 4506 8080
#ENTRYPOINT ["/usr/bin/salt-master","--log-level=info"]
ENTRYPOINT ["/usr/bin/supervisord","-c","/root/salt-supervisor.conf"]

RUN adduser --disabled-password --gecos "" labuser
RUN echo labuser:labpassword | chpasswd
