#!/bin/bash

set -euo pipefail

CERTS_DIR="$PWD/docker/certs"

if command -v podman >/dev/null; then
	ENGINE=podman
else
	ENGINE=docker
fi

if [ ! -f "$CERTS_DIR/ca.crt" ]; then
	mkdir -p "$CERTS_DIR"
	$ENGINE build -t certificate --target certificate ./docker
	$ENGINE rm -f -t0 certificate || true
	$ENGINE run -it --rm --pull=never -v "$CERTS_DIR":/etc/openvpn/certs:z --name certificate certificate:latest
fi

$ENGINE build -t ovpn-server --target openvpn ./docker
$ENGINE rm -f -t0 ovpn-server || true
$ENGINE run -d -it --pull=never -v "$CERTS_DIR":/etc/openvpn/certs:z -v /dev:/dev --privileged -p 1194:1194 --name ovpn-server ovpn-server:latest
