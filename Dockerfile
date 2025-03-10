FROM debian:bullseye-slim

ENV STEAM_APP_ID 2223650

ENV _STEAM_COMPAT_TOOLS /home/steam/.steam/root/compatibilitytools.d
ENV _PROTON_VERSION GE-Proton9-25
ENV _PROTON_PATH $_STEAM_COMPAT_TOOLS/$_PROTON_VERSION
ENV STEAM_COMPAT_DATA_PATH $_PROTON_PATH
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH ~/.steam/steam

ENV PATH="$PATH:$_PROTON_PATH"

ARG PUID=1000
ARG PGID=1000

# Use users group for unraid
RUN groupadd -g $PGID steam && useradd -d /home/steam -u $PUID -g $PGID -G users -m steam
RUN mkdir /app

# Install required packages
RUN set -ex; \
    dpkg --add-architecture i386; \
    apt update; \
    apt install -y --no-install-recommends wget curl jq sudo iproute2 procps software-properties-common dbus lib32gcc-s1 libfreetype6

# Download steamcmd
RUN set -ex; \
    mkdir -p /opt/steamcmd; \
    cd /opt/steamcmd; \
    curl "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Download Proton GE
RUN set -ex; \
    mkdir -p $_PROTON_PATH; \
    curl -sLOJ https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${_PROTON_VERSION}/${_PROTON_VERSION}.tar.gz; \
    tar -xzf GE-Proton*.tar.gz -C $_PROTON_PATH --strip-components=1; \
    rm GE-Proton*.tar.gz

# Proton Fix machine-id
RUN set -ex; \
    rm -f /etc/machine-id; \
    dbus-uuidgen --ensure=/etc/machine-id; \
    rm /var/lib/dbus/machine-id; \
    dbus-uuidgen --ensure

# Install tini
ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Set permissions
RUN set -ex; \
    chown -R steam:steam /app; \
    chown -R steam:steam /opt/steamcmd; \
    chown -R steam:steam /home/steam/.steam

# Copy entrypoint script
COPY --chown=steam --chmod=755 ./scripts/entrypoint.sh /app/entrypoint.sh

USER steam
WORKDIR /app

EXPOSE 7777/tcp
EXPOSE 7777/udp
EXPOSE 27015/tcp
EXPOSE 27015/udp

#on startup enter start.sh script
ENTRYPOINT ["/tini", "--", "/app/entrypoint.sh"]
