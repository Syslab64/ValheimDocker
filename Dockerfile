FROM debian:buster

# download requirements
RUN apt-get -y update && \
    apt-get -y install lib32gcc1 lib32stdc++6 curl && \
    apt-get clean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# setup steam user
RUN useradd -m steam
WORKDIR /home/steam
USER steam

COPY server_bepinex.sh .
COPY bepinexvalheim ./bepinexvalheim

# download steamcmd
RUN mkdir steamcmd && cd steamcmd && \
    curl "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# start steamcmd to force it to update itself
RUN ./steamcmd/steamcmd.sh +quit && \
    mkdir -pv /home/steam/.steam/sdk64/ && \
    ln -s /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

# opens ports for multiplayer
EXPOSE 2456-2458/udp

# start the server main script
ENTRYPOINT ["bash", "/home/steam/server_bepinex.sh"]

