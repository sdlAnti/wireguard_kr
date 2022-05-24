#!/bin/bash 
server_keygen () {
	if [ -e server_private_key ]
		then
			cat server_private_key
		else
			wg genkey | tee server_private_key | wg pubkey > server_public_key
			cat server_private_key
	fi
}

peer_keygen () {
        if [ -e peer_private_key ]
                then
                        cat peer_public_key
                else
                        wg genkey | tee peer_private_key | wg pubkey > peer_public_key
                        cat peer_public_key
        fi
}

peer_generation () {
cat << EOF
[Peer]
PublicKey = $(peer_keygen)
PresharedKey = /UwcSPg38hW/D9Y3tcS1FOV0K1wuURMbS0sesJEP5ak=
AllowedIPs = 0.0.0.0/0
Endpoint = demo.wireguard.com:51820


EOF
}

confgen () {
cat << EOF > 2.conf
[Interface]
Address = 10.10.10.1/24
PrivateKey = $(server_keygen)

$(peer_generation)

`echo 'PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT'`
`echo 'PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT'`
EOF
}

if [ -e 2.conf ]
	then
		echo conf file is exist
	else
		echo generating wireguard server and client conf
		confgen
fi
