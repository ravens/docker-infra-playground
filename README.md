# docker-infra-playground, RancherOS branch
Docker-based infrastructure deployment playground. Check the [master](https://github.com/ravens/docker-infra-playground/tree/master) branch to understand how the playground environement is working.

In this branch we explore RancherOS as OS for our virtual baremetals servers that will run docker based services, with everything triggered from cloud-based configuration files.

## architecture 

This is based on a mixture of microservices (for hosting the main infrastructure support, i.e. PXE bootstraping) and as well serving the minimim OS image to load on the virtual server cluster.

In our docker-compose.yml we define 3 nodes using infrasim:
 * a master, that will run K3s as server (DHCP IP 192.168.25.100)
 * 2 workers that will run K3s workers (DHCP IP 192.168.25.101 + 102)

We then have support services :
 * a DHCP and PXE UDP server at 192.168.25.2
 * a web server to serve the files to bootstrap the servers from scratch

 Interestings files that contain the configuration logic :
  * 

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

### console access to a virtual node on the virtual network

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