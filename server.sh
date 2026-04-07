#!/bin/bash

set -euo pipefail

podman build -t ovpn-server .
podman rm -f -t0 ovpn-server || true
podman run -d -it -v /dev:/dev --privileged --pull=never -p 1194:1194 --name ovpn-server localhost/ovpn-server
