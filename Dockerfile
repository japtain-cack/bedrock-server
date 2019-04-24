FROM ubuntu:bionic
LABEL author="Nathan Snow"
LABEL description="Minecraft Pocket Edition (Minecraft PE or Minecraft Bedrock) server"

WORKDIR /minecraft
ARG REV=1.11.0.23
ENV LD_LIBRARY_PATH=.
ENV MCPE_HOME=/minecraft
ENV BRSRVDIR=bedrock-server-$REV
ENV UID=1000
ENV GUID=1000
ENV LEVEL=world \
    PVP=true \
    VDIST=10 \
    OPPERM=4 \
    NETHER=true \
    FLY=false \
    MAXBHEIGHT=256 \
    NPCS=true \
    WLIST=false \
    ANIMALS=true \
    HC=false \
    ONLINE=false \
    RPACK='' \
    DIFFICULTY=3 \
    CMDBLOCK=false \
    MAXPLAYERS=20 \
    MONSTERS=true \
    STRUCTURES=true \
    SPAWNPROTECTION=16 \
    MODE=0 \
    CHEATS=false \
    SERVERNAME=dedicated-server

RUN apt-get -y update && apt-get -y install \
    sudo \
    unzip \
    curl \
    libcurl4 \
    libssl1.0.0

RUN curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${REV}.zip --output /tmp/${BRSRVDIR}.zip && \
    unzip /tmp/${BRSRVDIR}.zip -d /tmp/${BRSRVDIR} && \
    rm -fv /tmp/${BRSRVDIR}.zip

RUN groupadd -g $GUID minecraft && \
    useradd -s /bin/bash -d /minecraft -m minecraft -u $UID -g minecraft && \
    usermod -aG sudo minecraft

ADD ./scripts/run.sh /tmp/
RUN chmod +x /tmp/run.sh

VOLUME ["/minecraft"]

USER root

EXPOSE 19132/tcp
EXPOSE 19132/udp
EXPOSE 19133/tcp
EXPOSE 19133/udp

CMD trap 'exit' INT; /tmp/run.sh

