# docker-infra-playground, RancherOS branch
Docker-based infrastructure deployment playground. 
In this branch we explore RancherOS as OS for our virtual baremetals servers that will in turn run docker based services.

## architecture 

This is based on a mixture of microservices (for hosting the main infrastructure support, i.e. PXE bootstraping) and as well serving the minimim OS image to load on the virtual server cluster.

In our docker-compose.yml we define 3 nodes using infrasim:
- a master, that will run K3s as server
- 2 workers that will run K3s workers

## prepare

We need to fetch RancherOS based file to serve them from our local webserver
```
cd webroot
wget http://releases.rancher.com/os/latest/rancheros.iso # ISO to be installed on the virtual disk
wget http://releases.rancher.com/os/latest/vmlinuz # Kernel image to be booted on via PXE
wget http://releases.rancher.com/os/latest/initrd # Ramdisk to be booted on via PXE
```

## build and run

We use images stored on Docker Hub, although we are building a small image for dnsmasq and ssh due to the lack of more official image:
```
docker-compose pull && docker-compose build
docker-compose up
```

