# docker-infra-playground, RancherOS branch
Docker-based infrastructure deployment playground. Check the [master](https://github.com/ravens/docker-infra-playground/tree/master) branch to understand how the playground environment is typically working.

In this branch we explore [RancherOS](https://github.com/rancher/os) as a support OS to boot and configure and run [rancher-agent](https://github.com/rancher/agent) and manage the Kubernetes cluster via Rancher UI. 

## architecture 

This is based on a mixture of microservices (for hosting the main infrastructure support, i.e. PXE bootstraping) and as well serving the minimum OS image to load on the virtual server cluster.

Some diagram:

```
┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                                               │
│                                                          ┌────────┬────────┬────────┐                                                         │
│                                                          │        │        │        │                                                         │
│                                                          │ rancher│ rancher│ rancher│                                                         │
│                                                          │ agent  │ agent  │ agent  │                                                         │
│                                                          ├────────┼────────┼────────┤                                                         │
│                                                          │        │        │        │                                                         │
│                                                          │ Rancher│ Rancher│ Rancher│                                                         │
│                                                          │ OS .100│ OS .101│ OS .102│                                                         │
│                                                          ├────────┼────────┼────────┤                                                         │
│                                                          │        │        │        │                                                         │
│      ┌───────────┐    ┌────────┐    ┌────────┐           │  QEMU  │  QEMU  │  QEMU  │                                                         │
│      │           │    │        │    │        │           │        │        │        │                                                         │
│      │  dnsmasq  │    │  httpd │    │  sshd  │           ├────────┼────────┼────────┤                                                         │
│      │           │    │        │    │        │           │ br-bmc │ br-bmc │ br-bmc │                                                         │
│      └────┬──────┘    └────┬───┘    └───┬────┘           └───┬────┴────────┴────────┘                                                         │
│           │                │            │                    │                                          ┌───────────────────────┐             │
│           │                │            │                    │                                          │    192.168.25.0/24    │             │
│  ─────────▼────────────────▼────────────▼────────────────────▼──────────────────────────────────────────┴───────────────────────┴───▶         │
│   ┌───────────────┐ ┌───────────────┐ ┌───────────────┐   ┌──────────────────────────────────────────────────────┐                            │
│   │ 192.168.25.2  │ │ 192.168.25.3  │ │ 192.168.25.4  │   │       BMC: 192.168.25.6 (VNC+IPMI) - InfraSIM        │                            │
│   └─┬────────────┬┘ └─┬────────────┬┘ └─┬────────────┬┘   ├──────────────────────────────────────────────────────┤                            │
│     │ Container  │    │ Container  │    │ Container  │    │       BMC: 192.168.25.7 (VNC+IPMI) - InfraSIM        │                            │
│     └────────────┘    └────────────┘    └─────┬──────┘    ├──────────────────────────────────────────────────────┤                            │
│                                               │           │       BMC: 192.168.25.8 (VNC+IPMI) - InfraSIM        │                            │
│                                               │           └─┬────────────┬─┬────────────────────────┬────────────┘                            │
│                                               │             │ Container  │ │                        │                                         │
│                                               │             ├────────────┤ │                        │                                         │
│                                               │             │ Container  │ │                        │                                         │
│                                               │             ├────────────┤ │                        │                                         │
│                                               │             │ Container  │ │                        │                                         │
│     Physical host running docker-compose up   │             └────────────┘ │                        │                                         │
│     KVM required                              │                            │                        │                                         │
└───────────────────────────────────────────────┼────────────────────────────┼────────────────────────┼─────────────────────────────────────────┘
                                                │                            │                        │                                          
                                                │                            │                        │                                          
                                                ▼                            ▼                        ▼                                          
                           ┌─────┐    ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐                              
                           │Ports│    │   Port 2222 (SSH)   │    │  Port 5901-3 (VNC)  │    │   Port 623 (IPMI)   │                              
                           └─────┘    └─────────────────────┘    └─────────────────────┘    └─────────────────────┘                              
```

In our [docker-compose.yml](./docker-compose.yml) we define 3 nodes using an infrasim-based docker:
 * a master, that will run rancher-agent as etcd + control plane (DHCP IP 192.168.25.100)
 * 2 workers that will run rancher-agent as workers (DHCP IP 192.168.25.101 + 102)

We then have support services :
 * a DHCP and PXE UDP server at 192.168.25.2
 * a web server to serve the files to bootstrap the servers from scratch at 192.168.25.3
 * Rancher UI at 192.168.25.5

Interestings files that contain the configuration logic :
  * [boot.ipxe](./webroot/boot.ipxe) which is executed at PXE boot
  * [cloud-config.bootstrap.yaml](./webroot/cloud-config.bootstrap.yaml) to perform the first boot of the server, reformat it and configure the remote provisioning through a new cloud-config file
  * [cloud-config.yaml](./webroot/cloud-config.yaml) which is the actual configuration file (ssh keys, network interface, services...)
  * [cloud-config.bootstrap.yaml](./webroot/cloud-config.bootstrap.node.yaml) and [cloud-config.yaml](./webroot/cloud-config.node.yaml) for the worker node

  This is a playground, so there are no real optimization or clever use of the RancherOS yet. Just a basic usecase to start with playing with it.

Todos:
 * investigate if we can install RancherOS directly from the ramdisk rather then downloading a full ISO image and mounting it
 * prepare a kubectl environement within the SSH microservices to consume the K3S cluster

## prepare

We need to fetch RancherOS based file to serve them from our local webserver
```
cd webroot
wget http://releases.rancher.com/os/latest/rancheros.iso # ISO to be installed on the virtual disk
wget http://releases.rancher.com/os/latest/vmlinuz # Kernel image to be booted on via PXE
wget http://releases.rancher.com/os/latest/initrd # Ramdisk to be booted on via PXE
```

We need then to configure Rancher UI to generate the install token: 
```
docker-compose up -d rancher
```

Then go to https://localhost to configure Rancher UI password, create a custom cluster. Rancher UI will generate a token and certificate autority id that will need be to replace the ones provided in the provisioning files :
 * [cloud-config.yaml](./webroot/cloud-config.yaml)
 * [cloud-config.node.yaml](./webroot/cloud-config.node.node.yaml) 

Once this is done, we can start the whole simulated cluster.

## build and run

We use images stored on Docker Hub, although we are building a small image for dnsmasq and ssh due to the lack of more official image:
```
docker-compose pull && docker-compose build
docker-compose up
```

## interact with the virtual environment

### kubectl access to the virtual nodes on the virtual lab network

Once the 3 nodes have joined, the cluster will be operational. You can monitor the state within Rancher UI on https://localhost of the physical host executing the docker-compose.yml:
```
ssh localhost -l root -p 2222 # password *labpassword*, as defined in ssh/Dockerfile then
mkdir -p /root/.kube/
cat > /root/.kube/config # copy the kubeconfig.yaml from Rancher UI
kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts # remove RBAC
helm init --history-max 200
helm repo update 
```

### monitor the virtual nodes 

Using VNC on localhost port 5901, 5902 and 5903.
Using ipmi protocol tool such as ipmitool on port 623,624,625 with admin/admin. 
