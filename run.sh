#!/bin/bash -x
n=1
peers=5
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
if [ -e peer"$n"_private_key ]
    then
        if [ -e "peer"$n"_public_key" ]
            then
                cat "peer"$n"_public_key"
            else
                cat peer"$n"_private_key | wg pubkey > "peer"$n"_public_key"
                cat "peer"$n"_public_key"
        fi
    else
        wg genkey | tee "peer"$n"_private_key" | wg pubkey > "peer"$n"_public_key"
        chmod 600 "peer"$n"_private_key"
        cat "peer"$n"_public_key"
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
(( n++ ))
done
}

confgen () {
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

if [ -e wg0.conf ]
        then
                echo conf file is exist
        else
                echo generating wireguard server and client conf
                confgen
fi
