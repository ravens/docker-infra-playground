# docker-infra-playground, RancherOS vCPE branch
Docker-based infrastructure deployment playground. Check the [master](https://github.com/ravens/docker-infra-playground/tree/master) branch to understand how the playground environment is typically working.

In this branch we explore [RancherOS](https://github.com/rancher/os) as a support OS to boot and configure and run a vCPE NFV on top of the supporting OS.

## architecture 

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                                                                                               │
│                                                                             ┌────────────────┬────────────────────────────────┐               │
│                                                                             │                │                                │               │
│                                                                             │ Rancher        │ router     QEMU  + VyOS QCOW   │               │
│                                                                             │ OS .100        │ container                      │               │
│        ┌───────────┐    ┌────────┐    ┌────────┐                            ├────────────────┼────────────────────────────────┘               │
│        │           │    │        │    │        │                            │ QEMU           │                                                │
│        │  dnsmasq  │    │  httpd │    │  sshd  │                            ├────────┬───────┘                                                │
│        │           │    │        │    │        │                            │ br-bmc │                                                        │
│        └────┬──────┘    └────┬───┘    └───┬────┘                            └───┬────┘                                                        │
│             │                │            │                                     │                         ┌───────────────────────┐           │
│             │                │            │                                     │                         │    192.168.25.0/24    │           │
│    ─────────▼────────────────▼────────────▼─────────────────────────────────────▼─────────────────────────┴───────────────────────┴───▶       │
│     ┌───────────────┐ ┌───────────────┐ ┌───────────────┐   ┌──────────────────────────────────────────────────────┐                          │
│     │ 192.168.25.2  │ │ 192.168.25.3  │ │ 192.168.25.4  │   │       BMC: 192.168.25.6 (VNC+IPMI) - InfraSIM        │                          │
│     └─┬────────────┬┘ └─┬────────────┬┘ └─┬────────────┬┘   └────────────────┬────────────────────────┬────────────┘                          │
│       │ Container  │    │ Container  │    │ Container  │                     │                        │                                       │
│       └────────────┘    └────────────┘    └─────┬──────┘                     │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│                                                 │                            │                        │                                       │
│     Physical host running docker-compose up     │                            │                        │                                       │
│     KVM required                                │                            │                        │                                       │
└─────────────────────────────────────────────────┼────────────────────────────┼────────────────────────┼───────────────────────────────────────┘
                                                  │                            │                        │                                        
                                                  ▼                            ▼                        ▼                                        
                             ┌─────┐    ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐                            
                             │Ports│    │   Port 2222 (SSH)   │    │   Port 5901 (VNC)   │    │   Port 623 (IPMI)   │                            
                             └─────┘    └─────────────────────┘    └─────────────────────┘    └─────────────────────┘                            
```

## infrastructure preparation

We need to fetch RancherOS files to be able to boot locally:
```
cd webroot
wget http://releases.rancher.com/os/latest/rancheros.iso # ISO to be installed on the virtual disk
wget http://releases.rancher.com/os/latest/vmlinuz # Kernel image to be booted on via PXE
wget http://releases.rancher.com/os/latest/initrd # Ramdisk to be booted on via PXE
```

Then we need to build the container running the VM with the VyOS router software. 
We can then run the registryui container : 
```
docker-compose up -d registryui
```

This will make a registry available on port 5000 and its web interface for debug purpose on port 8000 of the physical host.

Time to build the vyos image. For this we use packer and docker-compose :
```
cd vyos-nfv
packer build -var-file=vyos-var.json vyos-image.json
docker-compose build
docker tag vyos-nfv_vyos-nfv:latest localhost:5000/vyos
docker push localhost:5000/vyos
```

This will generate the vyos.img in the vyos-nfv/build directory we will need for the vyos container image, and ship the resulting container in the lab registry. 

We can now run safely the rest of the lab infrastructure and our virtual node :
```
docker-compose up
```
The virtual node will put over PXE, install RancherOS on its hardrive, reboot and initiate a "router" service which is our VyOS NFV function instanciated with QEMU/KVM.  

### console access to the virtual nodes on the virtual lab network

```
ssh localhost -l root -p 2222 # password *labpassword*, as defined in ssh/Dockerfile then
ssh 192.168.25.100 -l rancher # to jump on the rancherOS virtualnode
```
