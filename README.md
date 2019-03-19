# docker-infra-playground, RancherOS branch
Docker-based infrastructure deployment playground. Check the [master](https://github.com/ravens/docker-infra-playground/tree/master) branch to understand how the playground environment is typically working.

In this branch we explore RancherOS as a support OS to boot and configure and run K3s, a lightweight Kubernetes cluster, also from Rancher.

## architecture 

This is based on a mixture of microservices (for hosting the main infrastructure support, i.e. PXE bootstraping) and as well serving the minimim OS image to load on the virtual server cluster.

In our [docker-compose.yml](./docker-compose.yml) we define 3 nodes using infrasim:
 * a master, that will run K3s as server (DHCP IP 192.168.25.100)
 * 2 workers that will run K3s workers (DHCP IP 192.168.25.101 + 102)

We then have support services :
 * a DHCP and PXE UDP server at 192.168.25.2
 * a web server to serve the files to bootstrap the servers from scratch

 Interestings files that contain the configuration logic :
  * [boot.ipxe](./webroot/boot.ipxe)
  * [cloud-config.bootstrap.yaml](./webroot/cloud-config.bootstrap.yaml) to perform the first boot of the server and reformat it and configure the remote provisioning through a new cloud-config file
  * [cloud-config.yaml](./webroot/cloud-config.yaml) which is the actual configuration file (ssh keys, network interface, services...)
  * [cloud-config.bootstrap.yaml](./webroot/cloud-config.bootstrap.node.yaml) and [cloud-config.yaml](./webroot/cloud-config.node.yaml) for the worker node

  This is a playground, so there are no real optimization or clever use of the RancherOS yet. Just a basic usecase to start with playing with it.

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

## interact with the virtual environment

### console access to the virtual nodes on the virtual lab network

```
ssh localhost -l root -p 2222 # password *labpassword*, as defined in ssh/Dockerfile then
# to access the first node, second node or third node
ssh 192.168.25.100 -l rancher 
ssh 192.168.25.101 -l rancher
ssh 192.168.25.102 -l rancher
```

To see the kubeconfig generated for this k3s cluster : 
```
ssh 192.168.25.100 -l rancher cat /tmp/k3soutput/kubeconfig.yaml
```

kubectl can now be use to control the minimal k3s cluster.

### monitor the virtual nodes 

Using VNC on localhost port 5901, 5902 and 5903.
Using ipmi protocol tool such as ipmitool on port 623,624,625 with admin/admin. 