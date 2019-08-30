FROM ubuntu:18.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update



RUN echo "[defaults]\nhost_key_checking = False" > /root/.ansible.cfg 
RUN echo "\npipelining=True">> /root/.ansible.cfg
RUN echo "\nforks=100" >> /root/.ansible.cfg

RUN apt-get -qy install vim
RUN apt-get -qy install screen tmux


WORKDIR /root

# per https://docs.openstack.org/kolla-ansible/stein/user/quickstart.html#recommended-reading instructions	
RUN apt-get -qy install python-pip
RUN apt-get -qy install python-dev libffi-dev gcc libssl-dev python-selinux python-setuptools
RUN apt-get -qy install python-virtualenv
RUN pip install -U pip
RUN apt-get -qy install ansible

RUN pip install kolla-ansible

ENTRYPOINT ["sleep","infinity"]