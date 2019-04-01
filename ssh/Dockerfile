FROM ubuntu:16.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

# ssh daemon, following docker example : https://docs.docker.com/engine/examples/running_ssh_service/
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:labpassword' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

RUN apt-get -qy install python-pip
RUN apt-get -qy install python-dev libffi-dev gcc libssl-dev python-selinux python-setuptools
RUN pip install ansible 
#RUN pip install kolla-ansible
WORKDIR /root
RUN apt-get -qy install git
RUN git clone https://github.com/openstack/kolla-ansible.git
WORKDIR /root/kolla-ansible
RUN git checkout stable/rocky
RUN pip install -r  requirements.txt
RUN python setup.py install
RUN apt-get -qy install ssh sshpass
RUN pip install python-openstackclient
RUN echo "[defaults]\nhost_key_checking = False" > /root/.ansible.cfg 
RUN apt-get -qy install vim
RUN pip install crudini