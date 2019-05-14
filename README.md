# docker-infra-playground, RancherOS vCPE branch
Docker-based infrastructure deployment playground. Check the [master](https://github.com/ravens/docker-infra-playground/tree/master) branch to understand how the playground environment is typically working.

In this branch we explore [RancherOS](https://github.com/rancher/os) as a support OS to boot and configure and later run a vCPE NFV function based on VyOS. 

## architecture 

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                               ┌────────────────┬────────────────────────────────┐             │
│                                                                               │                │                                │             │
│                                                                               │ Rancher        │ router     QEMU  + VyOS QCOW   │             │
│                                                                               │ OS .100        │ container                      │             │
│      ┌───────────┐ ┌────────┐ ┌────────┐ ┌──────────┐                         ├────────────────┼────────────────────────────────┘             │
│      │           │ │        │ │        │ │          │                         │ QEMU           │                                              │
│      │  dnsmasq  │ │ httpd  │ │  sshd  │ │ registry │                         ├────────┬───────┘                                              │
│      │           │ │        │ │        │ │          │                         │ br-bmc │                                                      │
│      └─────┬─────┘ └───┬────┘ └──┬─────┘ └──┬───────┘                         └───┬────┘                                                      │
│            │           │         │          │                                     │                         ┌───────────────────────┐         │
│            │           │         │          │                                     │                         │    192.168.25.0/24    │         │
│      ──────▼───────────▼─────────▼──────────▼─────────────────────────────────────▼─────────────────────────┴───────────────────────┴───▶     │
│         ┌──────┐    ┌─────┐   ┌─────┐    ┌─────┐ ┌─────┐      ┌──────────────────────────────────────────────────────┐                        │
│         │ 25.2 │    │25.3 │   │25.4 │    │25.5 │ │25.6 │      │       BMC: 192.168.25.7 (VNC+IPMI) - InfraSIM        │                        │
│         └──────┘    └─────┘   └──┬──┘    └───┬─┘ └──┬──┘      └────────────────┬────────────────────────┬────────────┘                        │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│                                  │           │      │                          │                        │                                     │
│     Physical host running docker-│ompose up  │      │                          │                        │                                     │
│     KVM required                 │           │      │                          │                        │                                     │
└──────────────────────────────────┼───────────┼──────┼──────────────────────────┼────────────────────────┼─────────────────────────────────────┘
                                   │           │      │                          │                        │                                      
                                   ▼           ▼      ▼                          ▼                        ▼                                      
                     ┌─────┐ ┌───────────┐ ┌─────────────────┐       ┌─────────────────────┐    ┌─────────────────────┐                          
                     │Ports│ │ Port 2222 │ │    Port 5000    │       │   Port 5901 (VNC)   │    │   Port 623 (IPMI)   │                          
                     └─────┘ │   (SSH)   │ │   (registry)    │       └─────────────────────┘    └─────────────────────┘                          
                             └───────────┘ │ Port 8000 (UI)  │                                                                                   
                                           └─────────────────┘                                                                                   
```

## infrastructure preparation

We need to fetch RancherOS files to be able to boot locally:
```
cd webroot
wget https://releases.rancher.com/os/latest/rancheros.iso # ISO to be installed on the virtual disk
wget https://releases.rancher.com/os/latest/vmlinuz # Kernel image to be booted on via PXE
wget https://releases.rancher.com/os/latest/initrd # Ramdisk to be booted on via PXE
cd ..
```

Then we need to build the container running the VM with the VyOS router software. 
We can now run the registryui container (that will instanciate a Docker registry) : 
```
docker-compose up -d registryui
```

This will make a registry available on port 5000 and its web interface for debug purpose on port 8000 of the physical host.

Time to build the vyos image. For this we use packer and docker-compose :
```
cd vyos-vm-service
# in case packer is needed : wget https://releases.hashicorp.com/packer/1.3.5/packer_1.3.5_linux_amd64.zip && 
sudo apt install python-bs4 # dependencies from our python script to pull the latest version
python vyos_iso_download.py # this will generate the updated packer command line to build the latest VyOS rolling release
packer build -var-file=vyos-var.json -var 'iso_url=https://downloads.vyos.io/rolling/current/amd64/vyos-1.2.0-rolling%2B201905140337-amd64.iso' -var 'iso_checksum=ab014e46588028a021c9adcfb48a32d94dce7f49' vyos.qcow2.json
docker-compose build
docker tag vyos-vm-service_vyos-vm-service:latest localhost:5000/vyos-vm-service
docker push localhost:5000/vyos-vm-service
cd ..
```

This will generate the vyos.img in the vyos-nfv/build directory, that we will need for the yos-vm-service container image, and ship the resulting container in the lab registry. 

We need now to prepare the saltminion container service that will be loaded in the RancherOS at boot. Using again docker-compose:
```
cd saltminion-service
docker-compose build
docker tag saltminion-service_saltminion-service:latest localhost:5000/saltminion-service
docker push localhost:5000/saltminion-service
cd ..
```

We need now to prepare the saltproxy container service that will be loaded in the RancherOS at boot. Using again docker-compose:
```
cd saltproxy-service
docker-compose build
docker tag saltproxy-service_saltproxy-service:latest localhost:5000/saltproxy-service
docker push localhost:5000/saltproxy-service
cd ..
```

We can now run safely the rest of the lab infrastructure and our virtual node :
```
docker-compose up
```
The virtual node will boot over PXE, install RancherOS on its hardrive at first boot, reboot and initiate a "router" service which is our VyOS NFV function instanciated with QEMU/KVM. You can watch the progress using VNC on localhost:5901.

### console access to the virtual nodes on the virtual lab network

```
ssh localhost -l root -p 2222 # password *labpassword*, as defined in ssh/Dockerfile then
ssh 192.168.25.100 -l rancher # to jump on the rancherOS virtualnode
ssh 192.168.25.101 -l labuser # to jump on the VyOS router
```

### vyos notes

 * Version of Debian used : https://wiki.vyos.net/wiki/Version_history
 * configuring the package repository :
 ```
set system package repository jessie components 'main contrib non-free'
set system package repository jessie distribution 'jessie'
set system package repository jessie url 'http://archive.debian.org/debian'
 ```
 * we prefer the injection of a debian package file using salt

### saltstack notes

Salt commands we can sue from the GUI (:8080) or from the saltmaster docker:
```
# refresh pillar
salt '*' saltutil.refresh_pillar
# executing vyos driver command from https://github.com/napalm-automation-community/napalm-vyos/blob/develop/napalm_vyos/vyos.py
salt 'vyosproxy' napalm.call load_merge_candidate config="set service lldp"
salt 'vyosproxy' napalm.call compare_config
salt 'vyosproxy' napalm.call commit_config
salt 'vyosproxy' napalm.call rollback
salt-run state.event pretty=True # observe the event stream on the master
```
