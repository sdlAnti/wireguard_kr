#!/bin/bash -x
PEERS=7
qr_enable=0
server_ip=`curl ifconfig.me`
peer_dns=77.88.8.8

peer_generation () {
    peer_path=peers/peer_"$n"
    peer_keygen    
    peer_ip=10.10.10.$(( `cat peer_ip.list | cut -f 4 -d '.' | tail -1` + 1 ))

    cat << EOF > $peer_path/peer_"$n"_wg.conf
[Interface]
PrivateKey = $(cat "$peer_path"/peer_"$n"_private_key)
Address = $peer_ip/32
DNS = $peer_dns

[Peer]
PublicKey = $(cat server_public_key)
Endpoint = $server_ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20
EOF

        echo $peer_ip >> peer_ip.list
        qr_generation
        (( n++ ))
}
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
qr_generation () {    
    if [ $qr_enable -eq 0 ]
        then
            return 
    elif [ $qr_enable -eq 1 ] && qrencode --version &> /dev/null
        then
            qrencode -t png -o "$peer_path"/peer_"$n"_qr.png -r "$peer_path"/peer_"$n"_wg.conf
            qrencode -t ansiutf8 < "$peer_path"/peer_"$n"_wg.conf
        else
            echo "qrencode not installed" 
            exit 1
    fi
}

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