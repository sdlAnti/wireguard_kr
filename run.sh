#!/bin/bash -x
n=1
peers=5
peer_dns=77.88.8.8
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

peer_keygen () {
peer_path=peers/peer"$n"
if [ -d $peer_path ]
    then
        if [ -e peer"$n"_private_key ]
            then
                cat peer"$n"_private_key | wg pubkey > peer"$n"_public_key
                cat peer"$n"_public_key
	    else
            cd $peer_path
	        wg genkey | tee peer"$n"_private_key | wg pubkey > peer"$n"_public_key
        	chmod 600 peer"$n"_private_key
	        cat peer"$n"_public_key
        fi
    else
        mkdir -p $peer_path
        cd $peer_path
        wg genkey | tee peer"$n"_private_key | wg pubkey > peer"$n"_public_key
        chmod 600 peer"$n"_private_key
        cat peer"$n"_public_key
fi
}

peer_generation () {
while [ $n -le $peers ]
do
cat << EOF
[Peer]
#Peer$n
PublicKey = $(peer_keygen)
PresharedKey =
AllowedIPs = 0.0.0.0/0
Endpoint = test.tld:51820

EOF

cat << EOF > peers/peer"$n"/peer"$n"_wg.conf
[Interface]
PrivateKey = $(cat peers/peer"$n"/peer"$n"_private_key)
Address = 10.10.10.$((1+$n))/32
DNS = $peer_dns

[Peer]
PublicKey = $(cat server_public_key)
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
EOF

(( n++ ))
done
}

confgen () {
server_ip=`curl -s zx2c4.com/ip | head -1`
cat << EOF > wg0.conf
[Interface]
Address = 10.10.10.1/24
ListenPort = 51820
PrivateKey = $(server_keygen)

`echo 'PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE'`
`echo 'PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE'`

$(peer_generation)

EOF
}


#if [ -e wg0.conf ]
#    then
#        echo conf file is exist
#    else
#        echo generating wireguard server and client conf
        confgen
#fi
