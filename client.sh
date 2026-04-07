#!/bin/bash

set -euo pipefail

rm -rf ./certs
podman cp ovpn-server:/etc/openvpn/certs/ ./certs

ca=$(cat ./certs/ca.crt | sed -e '/BEGIN CERTIFICATE/,/END CERTIFICATE/!d')
cert=$(cat ./certs/client.crt | sed -e '/BEGIN CERTIFICATE/,/END CERTIFICATE/!d')
key=$(cat ./certs/client.key | sed -e '/BEGIN PRIVATE KEY/,/END PRIVATE KEY/!d')

# get local ip, tricky, but better than 'ip a | grep ...'
host_ip=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

cat <<EOF >./client.ovpn
client
dev tun
proto tcp

remote $host_ip 1194

resolv-retry infinite
nobind
persist-key
persist-tun
connect-retry 2
connect-retry-max 0

cipher AES-256-GCM

verb 3

<ca>
$ca
</ca>

<cert>
$cert
</cert>

<key>
$key
</key>
EOF

if [ ! -f ics-openvpn-latest-stable.apk ]; then
	curl -sL "https://github.com/schwabe/ics-openvpn/releases/download/v0.7.64/ics-openvpn-0.7.64.apk" -o ics-openvpn-latest-stable.apk
fi
if [ ! -f burp.der ]; then
	curl -sL "http://localhost:8084/cert" -o burp.der
fi

adb install ics-openvpn-latest-stable.apk
adb push client.ovpn /storage/emulated/0/Download/
adb push burp.der /storage/emulated/0/Download/
