#!/bin/bash

set -euo pipefail

export EASYRSA_BATCH=1
export EASYRSA_REQ_CN="ovpn-server"

make-cadir /root/ovpn &&
	cd /root/ovpn &&
	./easyrsa init-pki &&
	./easyrsa build-ca nopass &&
	./easyrsa gen-req server nopass &&
	./easyrsa sign-req server server &&
	./easyrsa gen-req client nopass &&
	./easyrsa sign-req client client &&
	./easyrsa gen-dh

ls -Rlsah /etc/openvpn/certs

mkdir -p /etc/openvpn/certs &&
	cp /root/ovpn/pki/ca.crt /etc/openvpn/certs/ &&
	cp /root/ovpn/pki/issued/server.crt /etc/openvpn/certs/ &&
	cp /root/ovpn/pki/private/server.key /etc/openvpn/certs/ &&
	cp /root/ovpn/pki/issued/client.crt /etc/openvpn/certs/ &&
	cp /root/ovpn/pki/private/client.key /etc/openvpn/certs/ &&
	cp /root/ovpn/pki/dh.pem /etc/openvpn/certs/

ls -Rlsah /etc/openvpn/certs
