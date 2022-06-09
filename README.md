# Wireguard for Docker
Very simple [Wireguard®](https://www.wireguard.com/) server in a docker container

### Upstream links
GitHub: [sdlAnti/wireguard_kr](https://github.com/sdlAnti/wireguard_kr)  
Docker Repo: [sdlanti/wireguard_kr](https://hub.docker.com/r/sdlanti/wireguard_kr)  

## Quick Start guide  
### Manual run
On first start created one peer - "user"  

**With QR-code generation**
```
docker run -d --rm \
  --name=wireguard_kr \
  --cap-add sys_module \
  --cap-add net_admin \
  -e QR_ENABLE=1 \
  -v ~/wireguard:/etc/wireguard \
  -p 51820:51820/udp \
  sdlanti/wireguard_kr
```

**Witohout generate QR-code**
```
docker run -d --rm \
  --name=wireguard_kr \
  --cap-add sys_module \
  --cap-add net_admin \
  -v ~/wireguard:/etc/wireguard \
  -p 51820:51820/udp \
  sdlanti/wireguard_kr
```

### Using docker-compose  
docker-compose.yml sample
```
version: '3'
services:
  wireguard_kr:
    image: sdlanti/wireguard_kr
    environment:
      - PORT=51820
      - DNS=77.88.8.8, 8.8.8.8
      - QR_ENABLE=1
    volumes:
      - ~/wireguard/:/etc/wireguard/
    restart: always
    ports:
      - 51820:51820/udp
    cap_add:
      - SYS_MODULE
      - NET_ADMIN
```
after docker-compose.yaml file created
```
docker-compose up -d wireguard_kr
```
all keys and config files will bee save to *~/wireguard/* 

## How to use
### Environments 
One or two DNS servers for peers
```
DNS=77.88.8.8, 8.8.8.8
```
Generate QR code to *~/wireguard/peers/PEERNAME/PEERNAME_qr.png* and print to console 
```
QR_ENABLE=0
```
PEERS environment  == numbers of created users on image first start, by default does not exist
```
PEERS=4 
```
Custom wireguard server port
```
PORT=51820
```
### Create 5 clients with generate QR-codes
```
docker run -d --rm \
  --name=wireguard_kr \
  --cap-add sys_module \
  --cap-add net_admin \
  -e QR_ENABLE=1 \
  -e PEERS=5 \
  -v ~/wireguard:/etc/wireguard \
  -p 51820:51820/udp \
  sdlanti/wireguard_kr
```
### Create new client
Does not work if environmet PEERS is exist!
```
docker exec wireguard_kr addpeer clientname
```
If using docker-compose
```
docker-compose exec wireguard_kr addpeer clientname
```
If QR_ENABLE=1 QR-code will be save to peer dir *~/wireguard/peers/PEERNAME/PEERNAME_qr.png* and print to console
The new client will be automatically added to the current server configuration, no reboot required

### Reboot, restart, reload
The next time the container is started, the previously created configuration from ~/wireguard will be used.  
When new client was added, server automatically reload configuration.  