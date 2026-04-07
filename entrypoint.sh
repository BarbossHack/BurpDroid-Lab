#!/bin/bash

set -euo pipefail

host_ip=$(awk '/internal/ {print $1}' /etc/hosts)

# Redirect TCP traffic to BurpSuite running on the host machine
iptables -t nat -A PREROUTING -i tun0 -p tcp --dport 80 -j DNAT --to-destination "$host_ip":8084
iptables -t nat -A PREROUTING -i tun0 -p tcp --dport 443 -j DNAT --to-destination "$host_ip":8084

# Prevent QUIC traffic from bypassing the proxy (force android apps to use TCP instead of UDP for HTTP/3)
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p udp -j DROP

# Start OpenVPN server
openvpn --config /etc/openvpn/server/server.conf
