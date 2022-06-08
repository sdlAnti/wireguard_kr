#!/bin/bash
#get server public IP
server_ip=$(curl ifconfig.me)

wg_path=/etc/wireguard

#generate peer config
peer_generation () {
    peer_path="$wg_path"/peers/peer_"$n"
    peer_keygen    
    peer_ip=10.10.10.$(( `cat peer_ip.list | cut -f 4 -d '.' | tail -1` + 1 ))

    cat << EOF > "$peer_path"/peer_"$n"_wg.conf
[Interface]
PrivateKey = $(cat "$peer_path"/peer_"$n"_private_key)
Address = $peer_ip/32
DNS = $DNS

[Peer]
PublicKey = $(cat "$wg_path"/server_public_key)
Endpoint = $server_ip:$PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
EOF

        echo $peer_ip >> peer_ip.list
        qr_generation
        (( n++ ))
}

#generate peer public and client key
peer_keygen () {
if [ -d $peer_path ]
    then
        if [ -e "$peer_path"/peer_"$n"_private_key ]
            then
                cat "$peer_path"/peer_"$n"_private_key | wg pubkey > "$peer_path"/peer_"$n"_public_key
                cat "$peer_path"/peer_"$n"_public_key
	    else
	        wg genkey | tee "$peer_path"/peer_"$n"_private_key | wg pubkey > "$peer_path"/peer_"$n"_public_key
        	chmod 600 "$peer_path"/peer_"$n"_private_key
	        cat "$peer_path"/peer_"$n"_public_key
        fi
    else
        mkdir -p $peer_path
        wg genkey | tee "$peer_path"/peer_"$n"_private_key | wg pubkey > "$peer_path"/peer_"$n"_public_key
        chmod 600 "$peer_path"/peer_"$n"_private_key
        cat "$peer_path"/peer_"$n"_public_key
fi
}

#genetare QR-code, save to .png on peer dir and print to console 
qr_generation () {    
    if [ $QR_ENABLE -eq 0 ]
        then
            return 
    elif [ $QR_ENABLE -eq 1 ] && qrencode --version &> /dev/null
        then
            qrencode -t png -o "$peer_path"/peer_"$n"_qr.png -r "$peer_path"/peer_"$n"_wg.conf
            qrencode -t ansiutf8 < "$peer_path"/peer_"$n"_wg.conf
        else
            echo "qrencode not installed"
            exit 1
    fi
}

#generate multiply peers if env $PEERS exist or single peer
if [ $PEERS ]
    then 
        PEERNAME=${PEERS}
        n=1
        while [ $n -le $PEERNAME ]
        do
        peer_generation
        done
    else
        PEERNAME=$1
        n=$1
        if [ ! $PEERNAME  ]
            then
                echo "Peer name is empty"
                echo "For generate PEER: addpeer.sh <peername>"
                exit 0
        fi 
        peer_generation
fi