#!/bin/bash -x
#PEERS=4
PEERMANE=$1
n=1
qr_enable=0
    if [ ! $PEER ]
    then
        echo "Peer name is empty"
        echo "For generate PEER: addpeer.sh <peername>"
        exit 0
    fi 
peer_generation () {
    while [ $n -le $PEER ]
    do
        cat << EOF
[Peer]
#Peer$n
PublicKey = $(peer_keygen)
AllowedIPs = 10.10.10.$((1+$n))/32

EOF
        peer_path=peers/peer"$n"
        cat << EOF > $peer_path/peer"$n"_wg.conf
[Interface]
PrivateKey = $(cat "$peer_path"/peer"$n"_private_key)
Address = 10.10.10.$((1+$n))/32
DNS = $peer_dns

[Peer]
PublicKey = $(cat server_public_key)
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
EOF

        if [ $qr_enable -eq 1 ] && qrencode --version &> /dev/null
            then
                qrencode -t png -o "$peer_path"/peer"$n"_qr.png -r "$peer_path"/peer"$n"_wg.conf
            else
                echo "qrencode not installed" 
                exit 1
        fi

        (( n++ ))
    done
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
peer_generation