FROM mono:latest

ENV S6_VERSION=v1.21.4.0
ENV LANG=en_US.UTF-8
ENV HOMESEER_VERSION=4_2_22_4


RUN apt-get update && apt-get install -y \
    chromium \
    flite \
    wget \
    nano \
    iputils-ping \
    net-tools \
    etherwake \
    ssh-client \
    mosquitto-clients \
    mono-xsp4 \
    mono-vbnc \
    avahi-discover \
    libavahi-compat-libdnssd-dev \
    libnss-mdns \
    avahi-daemon avahi-utils mdns-scan \
    ffmpeg aha flite alsa-utils alsa-utils mono-devel \
    git make \
    xfonts-base xfonts-75dpi \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && touch /DO_INSTALL \
    && touch /DO_POLLYC_INSTALL

ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
    && tar -xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin \
    && rm -rf /tmp/* /var/tmp/*

ADD https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb /tmp/
RUN apt install -f /tmp/wkhtmltox_0.12.6-1.buster_amd64.deb

RUN if type sudo 2>/dev/null; then \ 
     echo "The sudo command already exists... Skipping."; \
    else \
     echo -e "#!/bin/sh\n\${@}" > /usr/bin/sudo; \
     chmod +x /usr/bin/sudo; \
    fi

COPY rootfs /

ARG AVAHI
RUN [ "${AVAHI:-1}" = "1" ] || (echo "Removing Avahi" && rm -rf /etc/services.d/avahi /etc/services.d/dbus)

VOLUME [ "/HomeSeer" ] 
EXPOSE 80 8888 10200 10300 10401 11000

ENTRYPOINT [ "/init" ]
