FROM docker.io/debian:13-slim

RUN apt update \
    && apt install -y openvpn easy-rsa iptables \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

ENV EASYRSA_BATCH=1
ENV EASYRSA_REQ_CN="ovpn-server"

# ---- PKI generation ----
RUN make-cadir /root/ovpn \
    && cd /root/ovpn \
    && ./easyrsa init-pki \
    && ./easyrsa build-ca nopass \
    && ./easyrsa gen-req server nopass \
    && ./easyrsa sign-req server server \
    && ./easyrsa gen-req client nopass \
    && ./easyrsa sign-req client client \
    && ./easyrsa gen-dh


# ---- Export usable artifacts ----
RUN mkdir -p /etc/openvpn/certs \
    && cp /root/ovpn/pki/ca.crt /etc/openvpn/certs/ \
    && cp /root/ovpn/pki/issued/server.crt /etc/openvpn/certs/ \
    && cp /root/ovpn/pki/private/server.key /etc/openvpn/certs/ \
    && cp /root/ovpn/pki/issued/client.crt /etc/openvpn/certs/ \
    && cp /root/ovpn/pki/private/client.key /etc/openvpn/certs/ \
    && cp /root/ovpn/pki/dh.pem /etc/openvpn/certs/

# ---- Server config ----
COPY server.conf /etc/openvpn/server/server.conf

# ---- Enable IP forwarding ----
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# ---- Run ----
COPY --chmod=777 entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
