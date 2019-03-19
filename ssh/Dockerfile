FROM ubuntu:16.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt install -qy python-dev python-virtualenv gcc

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

# Adding Kubectl for that particular playground
RUN apt-get update &&  apt-get install -yq curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN  mv ./kubectl /usr/local/bin/kubectl
RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz
RUN tar xvzf helm-v2.13.0-linux-amd64.tar.gz
RUN mv linux-amd64/helm linux-amd64/tiller  /usr/local/bin/
RUN chmod ugo+x /usr/local/bin/helm /usr/local/bin/tiller 
RUN rm -Rf linux-amd64/