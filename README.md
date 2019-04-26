# minecraft-bedrock
Run a bedrock server in a Docker container

[![Docker Automated build](https://img.shields.io/docker/automated/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Stars](https://img.shields.io/docker/stars/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Build Status](https://img.shields.io/docker/build/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server/builds)


This Dockerfile will download the Bedrock Server app and set it up, along with its dependencies.

If you run the container as is, the `worlds` directory will be created inside the container, which is unadvisable. It is highly recommended that you store your worlds outside the container using a mount (see the example below).

It is also likely that you will want to customize your `server.properties` file. The best way to do this is also using the `-e <environment var>=<value>` for each setting in the `server.properties`.

## Example
Here is a `docker run` command that will spin up a basic container with a few customized `server.properties`.

 $ `docker run -d -it --name=mcpe1 -v /opt/mcpe/world1:/minecraft -p 19132-19133:19132-19133/udp -p 19132-19133:19132-19133/tcp -e FLY=true -e OPS=usernameOne,usernameTwo-e ONLINE=false -e CHEATS=true -e SERVERNAME=mcpe.example.org nsnow/bedrock-server:latest`


## Additional Docker commands

*kil and remove all docker containers*
`docker kill $(docker ps -qa); docker rm $(docker ps -qa)`

*docker logs*
`docker logs mcpe1`

*attach to the minecraft server console*
`docker attach mcpe1`

*exec into the container's bash console*
`docker exec mcpe1 bash`

## Set selinux context for mounted volumes

`chcon -Rt svirt_sandbox_file_t /path/to/volume`

## List of server properties and environment variables
* UID=1000
* GUID=1000

*Bedrock server properties*
* "difficulty" "$DIFFICULTY"
* "level-type" "$LEVELTYPE"
* "server-name" "$SERVERNAME"
* "max-players" "$MAXPLAYERS"
* "server-port" "$PORT"
* "server-portv6" "$PORTV6"
* "level-name" "$LEVELNAME"
* "level-seed" "$SEED"
* "online-mode" "$ONLINEMODE"
* "white-list" "$WHITELIST"
* "allow-cheats" "$ALLOWCHEATS"
* "view-distance" "$VIEWDISTANCE"
* "player-idle-timeout" "$PLAYERIDLETIMEOUT"
* "max-threads" "$MAXTHREADS"
* "tick-distance" "$TICKDISTANCE"
* "default-player-permission-level" "$DEFAULTPLAYERPERMLEVEL"
* "texturepack-required" "$TEXTUREPACKREQUIRED"

*Java server settings that may/may not be supported*
* "motd" "$MOTD"
* "pvp" "$PVP"
* "op-permission-level" "$OPPERMLEVEL"
* "allow-nether" "$NETHER"
* "allow-flight" "$FLY"
* "max-build-height" "$MAXBUILDHEIGHT"
* "spawn-npcs" "$NPCS"
* "spawn-animals" "$ANIMALS"
* "hardcore" "$HARDCORE"
* "resource-pack" "$RESOURCEPACK"
* "enable-command-block" "$CMDBLOCK"
* "spawn-monsters" "$MONSTERS"
* "generate-structures" "$STRUCTURES"
* "spawn-protection" "$SPAWNPROTECTION"
* "max-tick-time" "$MAXTICKTIME"
* "max-world-size" "$MAXWORLDSIZE"
* "resource-pack-sha1" "$RESOURCEPACKSHA1"
* "network-compression-threshold" "$NETWORKCOMPRESSIONTHRESHOLD"
 
