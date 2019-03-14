# docker-infra-playground
Docker-based infrastructure deployment playground.

## background

Building automated infrastructure software is complicated, especially if you are dealing with baremetals. In order to increase repeatability, I wanted some basic environement that I can share with my peers without involving too much dependencies on the hardware.

I am using the following software components :
 * docker and docker-compose to run the 2 services (DHCP, web server) to serve a minimal bootstrapping environment around PXE. 
 * infrasim and QEMU to simulate a virtual node with a proper BMC (so IPMI protocol is available, like a physical node)

On the network side I am relying on default bridge from Docker. When the virtual node is initiated, I create an internal bridge with the original interface within the namespace so that QEMU can later on bridge its own TAP interface with it. 

This is the architectural diagram:
```
                                                                    ┌────────┐                                                      
                                                                    │        ├────────────────────────────────┐                     
                                                                    │  QEMU  │   PXE: DHCP, 192.168.25.100    │                     
                                                                    │        ├────────────────────────────────┘                     
    ┌───────────┐    ┌────────┐    ┌────────┐     ┌─────────────────┴────────┴──────┐                                               
    │           │    │        │    │        │     │                ┌─────────────┐  │                                               
    │  dnsmasq  │    │  httpd │    │  sshd  │     │  infrasim      │   br-bmc    │  │                                               
    │           │    │        │    │        │     │                └──────┬──────┘  │                                               
    └────┬──────┘    └────┬───┘    └───┬────┘     └───────────────────────┼─────────┘                                               
         │                │            │                                  │                            ┌───────────────────────┐    
         │                │            │                                  │                            │    192.168.25.0/24    │    
─────────▼────────────────▼────────────▼──────────────────────────────────▼────────────────────────────┴───────────────────────┴───▶
 ┌───────────────┐ ┌───────────────┐ ┌───────────────┐      ┌─────────────────────┐                                                 
 │ 192.168.25.2  │ │ 192.168.25.3  │ │ 192.168.25.4  │      │  BMC: 192.168.25.5  │                                                 
 └───────────────┘ └───────────────┘ └───────────────┘      └─────────────────────┘                                                 
```

## build and run

We use images stored on Docker Hub, although we are building a small image for dnsmasq due to the lack of more official image:
```
docker-compose pull && docker-compose build
```

Immediately the virtual node will boot over PXE once the docker-compose is started: 
```
docker-compose up
Creating network "docker-infra-playground_lab" with driver "bridge"
Creating docker-infra-playground_node_1 ... done
Creating docker-infra-playground_web_1  ... done
Creating docker-infra-playground_dhcp_1 ... done
Attaching to docker-infra-playground_web_1, docker-infra-playground_dhcp_1, docker-infra-playground_node_1

/* ... */ 

dhcp_1  | dnsmasq-dhcp: DHCPDISCOVER(eth0) 00:aa:bb:cc:dd:ee
dhcp_1  | dnsmasq-dhcp: DHCPOFFER(eth0) 192.168.25.104 00:aa:bb:cc:dd:ee
```

The current bootstrap process is involving the following files : 
 * tftproot/ files served by TFTP
 * webroot/ files served by HTTP, including an iPXE script (boot.ipxe)

The console for that node is available on port 5901, as well as a BMC access on localhost : 

```
ipmitool -H 127.0.0.1 -U admin -P admin power off
Chassis Power Control: Down/Off
```

This impacts immediatly the underlying QEMU instance within infrasim : 
```
node_1  |
node_1  | ==> /var/log/infrasim/default/runtime.log <==
node_1  | 2019-03-14 12:58:22,421 - Model - model.py:1813 - INFO - [compute] infrasim can't find numactl in this environment
node_1  | 2019-03-14 12:58:22,421 - Model - model.py:1620 - INFO - [ 47     ] default-node stop
node_1  | 2019-03-14 12:58:23,423 - Qemu - qemu.py:151 - INFO - qemu stopped
```
