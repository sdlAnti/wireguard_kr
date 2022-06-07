#!/bin/bash -x
#ENV section
n=1
peers=5
peer_dns=77.88.8.8
qr_enable=1

#cd /etc/wireguard

server_keygen () {
    if [ -e server_private_key ]
        then
            cat server_private_key
        else
            wg genkey | tee server_private_key | wg pubkey > server_public_key
            chmod 600 server_private_key
            cat server_private_key
    fi
}

confgen () {
    server_ip=`curl ifconfig.me`
    cat << EOF > wg0.conf
[Interface]
Address = 10.10.10.1/24
ListenPort = 51820
PrivateKey = $(server_keygen)

`echo 'PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE'`
`echo 'PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE'`

EOF
}

start_server () {
    for files in /home/sd--anti/wireguard/wg*.conf
	do
        echo "$(date): start interface - $files"
        echo "wg-quick up $files"
    done
}

if [ -e wg0.conf ]
    then
        echo conf file is exist, wireguard ready to start.
        exit 0
    else
        echo generating wireguard server and client conf
        confgen
        addpeer.sh test
fi
