#FROM ubuntu:focal
FROM debian:buster
RUN \
    echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    wireguard-tools \
    curl \
    iptables \
    qrencode \
    && apt-get clean all \
    procps 
WORKDIR /wireguard
ENV PATH="/wireguard/:${PATH}"
COPY run.sh /wireguard/
CMD run.sh && /bin/bash