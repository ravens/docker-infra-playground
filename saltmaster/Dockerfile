FROM ubuntu:18.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qy update
RUN apt-get -qy install curl gnupg
RUN curl -L https://bootstrap.saltstack.com -o install_salt.sh
RUN sh install_salt.sh -P -M
RUN apt-get -qy install salt-api 

RUN apt-get -qy install supervisor
COPY salt-supervisor.conf /root/salt-supervisor.conf
COPY salt-api.conf /etc/salt/master.d/salt-api.conf
#VOLUME ['/etc/salt/pki', '/var/cache/salt', '/var/logs/salt', '/etc/salt/master.d', '/srv/salt']
#COPY reactor.conf /etc/salt/master.d/reactor.conf

EXPOSE 4505 4506 8080
#ENTRYPOINT ["/usr/bin/salt-master","--log-level=info"]
ENTRYPOINT ["/usr/bin/supervisord","-c","/root/salt-supervisor.conf"]

RUN adduser --disabled-password --gecos "" labuser
RUN echo labuser:labpassword | chpasswd

RUN apt-get -qy install git
RUN git clone https://github.com/erwindon/SaltGUI.git
RUN mv SaltGUI/saltgui /srv 
