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

## build and run

We use images stored on Docker Hub, although we are building a small image for dnsmasq due to the lack of more official image:
```
docker-compose pull && docker-compose build && docker-compose up
```



