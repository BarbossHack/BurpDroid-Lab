#!/bin/bash

set -euo pipefail

CERTS_DIR="$PWD/docker/certs"

if [ ! -f "$CERTS_DIR/ca.crt" ]; then
	mkdir -p "$CERTS_DIR"
	podman build -t certificate --target certificate ./docker
	podman rm -f -t0 certificate || true
	podman run -it --rm --pull=never -v "$CERTS_DIR":/etc/openvpn/certs:z --name certificate certificate:latest
fi

podman build -t ovpn-server --target openvpn ./docker
podman rm -f -t0 ovpn-server || true
podman run -d -it --pull=never -v "$CERTS_DIR":/etc/openvpn/certs:z -v /dev:/dev --privileged -p 1194:1194 --name ovpn-server ovpn-server:latest
