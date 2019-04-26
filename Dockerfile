FROM ubuntu:bionic
LABEL author="Nathan Snow"
LABEL description="Minecraft Pocket Edition (Minecraft PE or Minecraft Bedrock) server"

WORKDIR /minecraft
ARG VER=1.11.0.23
ENV REV=$VER
ENV LD_LIBRARY_PATH=.
ENV MCPE_HOME=/minecraft
ENV BRSRVDIR=bedrock-server-$VER
ENV UID=1000
ENV GUID=1000

# Bedrock server properties
ENV MODE=0 \
    DIFFICULTY=1 \
    LEVELTYPE=default \
    SERVERNAME="Dedicated Server" \
    MAXPLAYERS=20 \
    PORT=19132 \
    PORTV6=19133 \
    LEVELNAME=level \
    SEED='' \
    ONLINEMODE=false \
    WHITELIST=false \
    ALLOWCHEATS=false \
    VIEWDISTANCE=10 \
    PLAYERIDLETIMEOUT=30 \
    MAXTHREADS=8 \
    TICKDISTANCE=4 \
    DEFAULTPLAYERPERMLEVEL=member \
    TEXTUREPACKREQUIRED=false

# Java server properties that may/may not be compatible
ENV MOTD='Welcom to Minecraft' \
    PVP=true \
    OPPERMLEVEL=4 \
    NETHER=true \
    FLY=false \
    MAXBUILDHEIGHT=256 \
    NPCS=true \
    ANIMALS=true \
    HARDCORE=false \
    RESOURCEPACK='' \
    RESOURCEPACKSHA1='' \
    CMDBLOCK=false \
    MONSTERS=true \
    STRUCTURES=true \
    SPAWNPROTECTION=16 \
    MAXTICKTIME=60000 \
    MAXWORLDSIZE=29999984 \
    NETWORKCOMPRESSIONTHRESHOLD=256

RUN apt-get -y update && apt-get -y install \
    sudo \
    unzip \
    curl \
    libcurl4 \
    libssl1.0.0

RUN groupadd -g $GUID minecraft && \
    useradd -s /bin/bash -d /minecraft -m minecraft -u $UID -g minecraft && \
    usermod -aG sudo minecraft && \
    echo "minecraft ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/minecraft

RUN curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${VER}.zip --output /tmp/${BRSRVDIR}.zip && \
    unzip /tmp/${BRSRVDIR}.zip -d /tmp/${BRSRVDIR} && \
    chown -R minecraft:minecraft /tmp/${BRSRVDIR} && \
    rm -fv /tmp/${BRSRVDIR}.zip

ADD ./scripts/run.sh /tmp/
RUN chmod +x /tmp/run.sh

VOLUME ["/minecraft"]

USER minecraft

EXPOSE 19132/tcp
EXPOSE 19132/udp
EXPOSE 19133/tcp
EXPOSE 19133/udp

CMD trap 'exit' INT; /tmp/run.sh

