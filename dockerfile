FROM ubuntu:18.04

LABEL maintainer="Manus AI"

# 1. Install Dependencies
RUN apt-get update && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    p7zip-full \
    lib32gcc1 \
    lib32stdc++6 \
    libjson-xs-perl \
    libdbd-mysql-perl \
    mysql-client \
    perl \
    screen \
    gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Create a non-root user
RUN useradd -m -s /bin/bash dayz
USER dayz
WORKDIR /home/dayz

# 3. Install SteamCMD
RUN mkdir -p /home/dayz/steamcmd && \
    cd /home/dayz/steamcmd && \
    wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zx

# 4. Copy server files and scripts first
COPY --chown=dayz:dayz config/ /home/dayz/server/cfgdayz/
COPY --chown=dayz:dayz sql/ /home/dayz/server/sql/
COPY --chown=dayz:dayz scripts/ /home/dayz/server/

# 5. Set permissions and compile utilities
RUN chmod +x /home/dayz/server/*.sh /home/dayz/server/*.pl && \
    cd /home/dayz/server && \
    gcc -o tolower tolower.c && \
    ./tolower && \
    rm tolower.c tolower

# 6. Install Arma 2 and DayZ Epoch (moved after permission setup)
RUN cd /home/dayz/server && \
    ./install_server.sh

# 7. Set up the environment
ENV LD_LIBRARY_PATH=/home/dayz/server
WORKDIR /home/dayz/server

# 8. Expose the server port
EXPOSE 2302/udp

# 9. Set the entrypoint
ENTRYPOINT ["/home/dayz/server/entrypoint.sh"]

