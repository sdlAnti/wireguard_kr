#FROM ubuntu:focal
FROM debian:buster-slim
RUN \
    echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    iproute2 \
    wireguard-tools \
    curl \
    iptables \
    qrencode \
    procps \
    && apt-get clean all \ 
WORKDIR /wireguard
ENV PATH="/wireguard/:${PATH}"
COPY run.sh /wireguard/
CMD run.sh && wg-quick up /etc/wireguard/wg0.conf