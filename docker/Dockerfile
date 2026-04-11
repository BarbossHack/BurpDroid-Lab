FROM docker.io/debian:13-slim AS certificate

RUN apt update \
    && apt install -y easy-rsa \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=777 gen-certs.sh /usr/local/bin/gen-certs.sh
CMD ["/usr/local/bin/gen-certs.sh"]

FROM docker.io/debian:13-slim AS openvpn

RUN apt update \
    && apt install -y openvpn iptables \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

COPY server.conf /etc/openvpn/server/server.conf
COPY certs/ /etc/openvpn/server/certs/

COPY --chmod=777 entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
