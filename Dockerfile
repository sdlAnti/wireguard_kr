#FROM ubuntu:focal
FROM debian:buster-slim
RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    iproute2 \
    wireguard-tools \
    curl \
    iptables \
    qrencode \
    procps \
    inotify-tools \
    && apt-get clean all \ 
    && rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

#qr code generation
ENV QR_ENABLE=0   
ENV DNS=77.88.8.8
ENV PORT=51820


WORKDIR /wireguard
ENV PATH="/wireguard/:${PATH}"
COPY run.sh addpeer.sh peer_ip.list /wireguard/
#COPY run.sh addpeer.sh /wireguard/
CMD ["run.sh"]