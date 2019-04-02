# docker-infra-playground - ubuntu branch
Docker-based infrastructure deployment playground. In this playground we deploy automatically some ubuntu server using a preseed configuration file.


## architecture

```
                                                            ┌────────┐                                           
                                                            │        ├──────────────┐                            
                                                            │  QEMU  │  PXE: DHCP   │                            
                                                            │        ├──────────────┘                            
    ┌───────────┐    ┌───────────┐        ┌─────────────────┴────────┴──────┐                                    
    │           │    │           │        │                ┌─────────────┐  │                                    
    │  dnsmasq  │    │  httpd    │        │  infrasim      │   br-bmc    │  │                                    
    │           │    │           │        │                └──────┬──────┘  │                                    
    └────┬──────┘    └────┬──────┘        └───────────────────────┼─────────┘                                    
         │                │                                       │                  ┌───────────────────────┐   
         │                │                                       │                  │    192.168.25.0/24    │   
─────────▼────────────────▼───────────────────────────────────────▼──────────────────┴───────────────────────┴──▶
 ┌───────────────┐ ┌───────────────┐                ┌─────────────────────┐                                      
 │ 192.168.25.2  │ │ 192.168.25.3  │                │  BMC: 192.168.25.4  │                                      
 └───────────────┘ └───────────────┘                └─────────────────────┘                                      
```

## build and run the infrastructure

We use images stored on Docker Hub, although we are building a small image for dnsmasq due to the lack of more official image:
```
docker-compose pull && docker-compose build && docker-compose up
```
## installing openstack using Kolla based deployment

First let's verify that all 3 nodes are up and running (using SSH/VNC). Once this is ready, we can log in in our ssh service and start Kolla deployment as noted in their documentation :

```
ansible -m ping -i /inventory/lab all # check if all the baremetals/VM are ready
kolla-genpwd
kolla-ansible -i /inventory/lab bootstrap-servers
kolla-ansible -i /inventory/lab prechecks
kolla-ansible -i /inventory/lab deploy
kolla-ansible -i /inventory/lab post-deploy
kolla-ansible -i /inventory/lab check
source /etc/kolla/admin-openrc.sh
# create public network
openstack network create --external --provider-physical-network physnet1 --provider-network-type flat public1
openstack subnet create --no-dhcp --allocation-pool start=192.168.25.150,end=192.168.25.170 --network public1 --subnet-range 192.168.25.0/24 --gateway 192.168.25.1 public1-subnet
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

Most kolla parameters are driven by the files in [ssh/kolla](./ssh/kolla), using Ansible inventory that I preconfigured for this playground [ssh/inventory](./ssh/inventory/lab).