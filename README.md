# minecraft-bedrock
Run a bedrock server in a Docker container

[![Docker Automated build](https://img.shields.io/docker/automated/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Stars](https://img.shields.io/docker/stars/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Build Status](https://img.shields.io/docker/build/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server/builds)


This Dockerfile will download the Bedrock Server app and set it up, along with its dependencies.

If you run the container as is, the `worlds` directory will be created inside the container, which is unadvisable. It is highly recommended that you store your worlds outside the container using a mount (see the example below).

It is also likely that you will want to customize your `server.properties` file. The best way to do this is also using the `-e <environment var>:<value>` for each setting in the `server.properties`.

## Example
Here is a `docker run` command that will spin up a basic container with a few customized `server.properties`.

 $ `docker run -d -it --name=mcpe1 -v /opt/mcpe:/minecraft -p 19132-19132:19133-19133/udp -p 19132-19132:19133-19133/tcp -e FLY=true -e OPS=usernameOne,usernameTwo-e ONLINE=false -e CHEATS=true -e SERVERNAME=mcpe.example.org nsnow/bedrock-server:latest`


## Additional Docker commands

`docker kill $(docker ps -qa); docker rm $(docker ps -qa)`

`docker logs mcpe1`

## Set selinux context for mounted volumes

`chcon -Rt svirt_sandbox_file_t /path/to/volume`

## List of environment variables and their defaults
* UID=1000
* GUID=1000
* LEVEL=world
* PVP=true
* VDIST=10
* OPPERM=4
* NETHER=true
* FLY=false
* MAXBHEIGHT=256
* NPCS=true
* WLIST=false
* ANIMALS=true
* HC=false
* ONLINE=false
* RPACK=''
* DIFFICULTY=3
* CMDBLOCK=false
* MAXPLAYERS=20
* MONSTERS=true
* STRUCTURES=true
* SPAWNPROTECTION=16
* MODE=0
* CHEATS=false
* SERVERNAME=dedicated-server
* MOTD=''
* LEVEL=''
* SEED=''
* MAX_TICK_TIME=''
* MAX_WORLD_SIZE=''
* RPACK_SHA1=''
* NETWORK_COMPRESSION_THRESHOLD=''

