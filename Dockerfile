# Build remco from specific commit
##################################
FROM golang

ENV REMCO_VERSION v0.11.1

# remco (lightweight configuration management tool) https://github.com/HeavyHorst/remco
RUN go get github.com/HeavyHorst/remco/cmd/remco
RUN cd $GOPATH/src/github.com/HeavyHorst/remco && \
    git checkout ${REMCO_VERSION}
RUN go install github.com/HeavyHorst/remco/cmd/remco

# Build base container
######################
FROM ubuntu:bionic
LABEL author="Nathan Snow"
LABEL description="Minecraft Pocket Edition (Minecraft PE or Minecraft Bedrock) server"
user root

ENV DEBIAN_FRONTEND noninteractive
ENV TINI_VERSION v0.18.0
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ARG BEDROCK_VERSION=
ENV BEDROCK_VERSION=$BEDROCK_VERSION
ENV LD_LIBRARY_PATH=.
ENV MCPE_HOME=/home/minecraft
ENV UID=1000
ENV GUID=1000

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    sudo \
    unzip \
    curl \
    libcurl4 \
    libssl1.0.0 \
    wget \
    git \
    gnupg2

RUN groupadd -g $GUID minecraft && \
    useradd -s /bin/bash -d /home/minecraft -m -u $UID -g minecraft minecraft && \
    passwd -d minecraft && \
    echo "minecraft ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/minecraft

# Add Tini (A tiny but valid init for containers) https://github.com/krallin/tini
RUN wget -O /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    wget -O /tini.asc https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc && \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
    gpg --batch --verify /tini.asc /tini && \
    chmod +x /tini

COPY --from=0 /go/bin/remco /usr/local/bin/remco
COPY --chown=minecraft:root remco /etc/remco
RUN chmod -R 0775 etc/remco

EXPOSE 19132/tcp
EXPOSE 19132/udp
EXPOSE 19133/tcp
EXPOSE 19133/udp

USER minecraft
WORKDIR /home/minecraft
VOLUME ["/home/minecraft/server"]

COPY --chown=minecraft:minecraft files/get-version.sh ./
COPY --chown=minecraft:minecraft files/entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["/tini", "--", "./entrypoint.sh"]

