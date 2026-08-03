#!/bin/bash

set -euo pipefail

NFT=burpdroid
NETNS=burpns
IFHOST=veth-burp
IFNS=veth-burpd-ns
BURP_PORT=8084
EGRESS_IF=$(ip route show default | awk '{print $5; exit}')

function reset() {
	sudo ip netns del $NETNS 2>/dev/null || true
	sudo nft delete table ip $NFT 2>/dev/null || true
	sudo ip link del $IFHOST 2>/dev/null || true
}

if [ "${1:-}" == "reset" ]; then
	reset
	exit 0
fi

reset

# Create namespace and veth pair
sudo ip netns add $NETNS
sudo ip link add $IFHOST type veth peer name $IFNS netns $NETNS

sudo ip addr add 10.200.1.1/24 dev $IFHOST
sudo ip link set $IFHOST up

sudo ip -n $NETNS addr add 10.200.1.2/24 dev $IFNS
sudo ip -n $NETNS link set $IFNS up
sudo ip -n $NETNS link set lo up
sudo ip -n $NETNS route add default via 10.200.1.1

# Namespace DNS resolution
sudo mkdir -p /etc/netns/$NETNS
echo "nameserver 1.1.1.1" | sudo tee /etc/netns/$NETNS/resolv.conf >/dev/null

# IP forwarding
sudo sysctl -qw net.ipv4.ip_forward=1

# NAT rules for redirecting traffic to Burp Suite
sudo nft -f - <<EOF
table ip $NFT {
    chain postrouting {
        type nat hook postrouting priority 100;
        ip saddr 10.200.1.0/24 oifname "$EGRESS_IF" masquerade
    }
    chain prerouting {
        type nat hook prerouting priority dstnat;
        iifname "$IFHOST" tcp dport { 80, 443 } redirect to :$BURP_PORT
		# or redirect everything:
        # iifname "$IFHOST" meta l4proto tcp redirect to :$BURP_PORT
    }
	chain output {
        type filter hook output priority filter; policy accept;
		# block QUICK
        iifname "$IFHOST" udp dport { 80, 443 } drop
        # or block everything:
        # iifname "$IFHOST" meta l4proto udp drop
	}
}
EOF

if [ ! -f burp.der ]; then
	curl -sL "http://localhost:$BURP_PORT/cert" -o burp.der
fi
