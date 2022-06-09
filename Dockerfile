FROM debian:buster-slim
LABEL   version="1.0" \
        mainteiner="sd--anti@yandex.ru" \
        description="wireguard VPN"

#qr code generation
ENV QR_ENABLE=0

#DNS servers
ENV DNS=77.88.8.8

#wireguard default port
ENV PORT=51820

#add "/wireguard/:" to $PATH, for run scripts without "./"
ENV PATH="/wireguard/:${PATH}"

WORKDIR /wireguard
COPY run addpeer peer_ip.list /wireguard/
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
    #clean section
    && apt-get clean all \ 
    && rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

CMD ["run"]