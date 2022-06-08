#!/bin/bash -x
#ENV section

wg_path=/etc/wireguard

server_keygen () {
    if [ -e server_private_key ]
        then
            cat "$wg_path"/server_private_key
        else
            wg genkey | tee "$wg_path"/server_private_key | wg pubkey > "$wg_path"/server_public_key
            chmod 600 "$wg_path"/server_private_key
            cat "$wg_path"/server_private_key
    fi
}

confgen () {
    server_ip=`curl ifconfig.me`
    cat << EOF > "$wg_path"/wg0.conf
[Interface]
Address = 10.10.10.1/24
ListenPort = 51820
PrivateKey = $(server_keygen)

`echo 'PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE'`
`echo 'PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE'`

EOF
}

start_server () {
    for files in "$wg_path"/wg*.conf
	do
        echo "$(date): start interface - $files"
        wg-quick up $files       
    done
    for files in "$wg_path"/peers/peer_*/*public_key
    do
        PUBKEY=$(cat $files)
        AIP=$(cat $(echo $files | sed 's/public_key/wg.conf/') | sed -n '3 s/Address = //p')
        wg set wg0 peer $PUBKEY allowed-ips $AIP
    done
}

stop_server () {
    for files in "$wg_path"/wg*.conf
	do
        echo "$(date): stop interface - $files"
        wg-quick down $files
    done
}

if [ ! -e "$wg_path"/wg0.conf ]
    then
        echo generating wireguard server and client conf
        confgen
        addpeer.sh test
fi

start_server

while inotifywait -e modify -e create /etc/wireguard/peers
do
	stop_server
	start_server
done