# docker-infra-playground - Openstack Kolla branch
Docker-based infrastructure deployment playground. 

In this playground we generate an environement suitable to deploy Openstack Kolla on a 3 nodes : 1 controller, 2 computes with two networks : management (192.168.25.0/24) and dataplane (192.168.26.0/24). You need a KVM-based machine with a lot of memory (16GB) minimum.

When running the docker-compose, it will instanciate a couple of VM (3) with nested virtualization inside. As well, a DHCP server and an SSH daemon will be instanciated as microservices. Using that, the virtual servers will boot over PXE, install some ubuntu in automated mode (using preseed functionality). 

Once the ubuntu servers are installed, you can proceed with deployment openstack "by-hand" using the Kolla approach methodology which relies on ansible to deploy docker-based containers on each hosts. 

## architecture

```
─────────────────────────────────────────────────▲────────────────▲────────────────▲────────────────────┬───────────────────────┬──▶ 
                                                 │                │                │                    │    192.168.26.0/24    │    
                                                 │                │                │                    ├───────────────────────┤    
                                                 │                │                │                    │   Dataplane network   │    
                                                 │                │                │                    └───────────────────────┘    
                     ┌─────────────────┐         │                │                │                                                 
                     │                 ├──┐      │                │                │                                                 
                     │  kolla-ansible  │  │      │                │                │                                                 
                     │                 │  │      │                │                │                                                 
                     └──▲──────────────┘  │   ┌──┴─────────────┬──┴─────────────┬──┴─────────────┐                                   
                        │                 └───▶ Ubuntu 16.04   │ Ubuntu 16.04   │ Ubuntu 16.04   │                                   
                        │                     │ 25.100         │ 25.101         │ 25.102         │                                   
 ┌───────┐┌────────┐┌───┴───┐   ┌───────┐     ├────────────────┼────────────────┼────────────────┤                                   
 │       ││        ││       │   │       │     │ InfraSIM       │ InfraSIM       │ InfraSIM       │                                   
 │dnsmasq││ httpd  ││  sshd │   │ salt  │     ├────────┬───────┼────────┬───────┴┬────────┬──────┘                                   
 │       ││        ││       │   │       │     │ br-bmc │       │ br-bmc │        │ br-bmc │                                          
 └────┬──┘└───┬────┘└────┬──┘   └───┬───┘     └─┬──────┘       └────────┘        └────────┘                                          
      │       │          │          │           │                                                       ┌───────────────────────┐    
      │       │          │          │           │                                                       │    192.168.25.0/24    │    
 ─────▼───────▼──────────▼──────────▼───────────▼───────────────────────────────────────────────────────┼───────────────────────┼───▶
  ┌──────┐ ┌─────┐   ┌─────┐     ┌─────┐     ┌──────────────────────────────────┐                       │  Management network   │    
  │ 25.2 │ │25.3 │   │25.4 │     │25.5 │     │  BMC: 192.168.25.6 (VNC+IPMI) -  │                       └───────────────────────┘    
  └──────┘ └─────┘   └─┬───┘     └─────┘     ├──────────────────────────────────┤                                                    
                       │                     │  BMC: 192.168.25.7 (VNC+IPMI) -  │                                                    
                       │                     ├──────────────────────────────────┤                                                    
                       │                     │  BMC: 192.168.25.8 (VNC+IPMI) -  │                                                    
                       │                     └─────────────────────────────┬────┘                                                    
                       ▼                                                   │                                                         
                 ┌───────────┐                                             ▼                                                         
                 │ Port 2222 │         ┌─────────────────────┬─────────────────────┐                                                 
      ┌─────┐    │   (SSH)   │         │   Port 5901 (VNC)   │   Port 623 (IPMI)   │                                                 
      │Ports│    └───────────┘         ├─────────────────────┼─────────────────────┤                                                 
      └─────┘                          │   Port 5902 (VNC)   │   Port 624 (IPMI)   │                                                 
                                       ├─────────────────────┼─────────────────────┤                                                 
                                       │   Port 5903 (VNC)   │   Port 625 (IPMI)   │                                                 
                                       └─────────────────────┴─────────────────────┘                                                 
```

## build and run the infrastructure

We use images stored on Docker Hub, although we are building a small image for dnsmasq due to the lack of more official image:
```
docker-compose pull && docker-compose build && docker-compose up
```

The easiest way to monitor deployment on the simulated baremetals server is to watch the activity on the web server:
```
web_1             | 192.168.25.102 - - [02/Sep/2019:08:15:07 +0000] "GET /boot-kolla.ipxe HTTP/1.1" 200 553
web_1             | 192.168.25.100 - - [02/Sep/2019:08:15:07 +0000] "GET /boot-kolla.ipxe HTTP/1.1" 200 553
web_1             | 192.168.25.101 - - [02/Sep/2019:08:15:07 +0000] "GET /boot-kolla.ipxe HTTP/1.1" 200 553
web_1             | 192.168.25.100 - - [02/Sep/2019:08:15:37 +0000] "GET /preseed-kolla.cfg HTTP/1.1" 200 3193
web_1             | 192.168.25.101 - - [02/Sep/2019:08:15:38 +0000] "GET /preseed-kolla.cfg HTTP/1.1" 200 3193
web_1             | 192.168.25.102 - - [02/Sep/2019:08:15:38 +0000] "GET /preseed-kolla.cfg HTTP/1.1" 200 3193
web_1             | 192.168.25.101 - - [02/Sep/2019:08:57:15 +0000] "GET /postinst-kolla.sh HTTP/1.1" 200 146
web_1             | 192.168.25.101 - - [02/Sep/2019:08:57:16 +0000] "GET /ok HTTP/1.1" 200 3
web_1             | 192.168.25.100 - - [02/Sep/2019:08:58:31 +0000] "GET /postinst-kolla.sh HTTP/1.1" 200 146
web_1             | 192.168.25.100 - - [02/Sep/2019:08:58:32 +0000] "GET /ok HTTP/1.1" 200 3
web_1             | 192.168.25.102 - - [02/Sep/2019:09:00:24 +0000] "GET /postinst-kolla.sh HTTP/1.1" 200 146
web_1             | 192.168.25.102 - - [02/Sep/2019:09:00:24 +0000] "GET /ok HTTP/1.1" 200 3
```

We can watch over the ipxe script to be served, the preseed file to be served to the ubuntu installer, as well as a final empty "ok" file getting fetched at the very end of the installation. It also gives you a timing of the install on a i7 with 16GB of memory (roughly, 30s to get ubuntu to fetch the preseed stage, and 45 min to the full parallel 3 nodes install).

## installing openstack using Kolla based deployment

First let's verify that all 3 nodes are up and running (using SSH/VNC). Once this is ready, we can log in in our ssh service and start Kolla deployment as noted in their documentation :

```
ansible -m ping -i /inventory/multinode all # check if all the baremetals/VM are ready
kolla-genpwd
kolla-ansible -i /inventory/multinode bootstrap-servers
kolla-ansible -i /inventory/multinode prechecks
kolla-ansible -i /inventory/multinode deploy
kolla-ansible -i /inventory/multinode post-deploy
kolla-ansible -i /inventory/multinode check
source /etc/kolla/admin-openrc.sh
# create public network
openstack network create --external --provider-physical-network physnet1 --provider-network-type flat public1
openstack subnet create --no-dhcp --allocation-pool start=192.168.26.150,end=192.168.26.170 --network public1 --subnet-range 192.168.26.0/24 --gateway 192.168.26.1 public1-subnet
# adding flavor
openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 m1.tiny
openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
openstack flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
openstack flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge
# create labsuser/labpassword user with admin level
openstack project create --description 'Openstack Lab' lab --domain default
openstack user create --project lab --password labpassword labuser
openstack role add --user labuser --project lab admin
```

Most kolla parameters are driven by the files in [provisioner/kolla](./provisioner/kolla), using Ansible inventory that I preconfigured for this playground [provisioner/inventory](./provisioner/inventory/lab).
