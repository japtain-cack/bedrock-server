# bedrock-server
Run a Minecraft Bedrock server in a Docker container.

Now with automatic bedrock server updates and envforge config management. Just restart the container.

[![Docker Automated build](https://img.shields.io/docker/automated/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Stars](https://img.shields.io/docker/stars/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Build Status](https://img.shields.io/docker/build/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server/builds)

## Features

- **Multi-stage build** for optimized image size
- **Automatic version detection** using Puppeteer or shell scripts
- **Configuration templating** with envforge
- **Non-root execution** for better security
- **Health checks** for container monitoring
- **Automatic updates** - just restart to get the latest Minecraft version

## Important Notes

This Dockerfile will download the Bedrock Server app and set it up, along with its dependencies.

**Data Persistence**: If you run the container as is, the `worlds` directory will be created inside the container, which is inadvisable. It is highly recommended that you store your worlds outside the container using a mount (see the example below). Ensure that your file system permissions are correct, `chown 1000:1000 mount/path`, or modify the UID/GID variables as needed (see below).

**Configuration**: You can customize your `server.properties` file using environment variables. The `server.properties` file will be regenerated from templates every time the container is launched, allowing for dynamic configuration.


## Run the server

Use this `docker run` command to launch a container with a few customized `server.properties`.

```
docker run -d -it --name=mcpe1 -v \
  /opt/mcpe/world1:/home/minecraft/server -p 19132-19133:19132-19133/udp -p 19132-19133:19132-19133/tcp \
  -e MINECRAFT_ONLINE-MODE=false \
  -e MINECRAFT_ALLOW-CHEATS=true \
  -e MINECRAFT_SERVER-NAME=mcpe.example.org \
  nsnow/bedrock-server:latest
```

## Additional Docker commands

**kill and remove all docker containers**

`docker kill $(docker ps -qa); docker rm $(docker ps -qa)`

**docker logs**

`docker logs mcpe1`

**attach to the minecraft server console**

you don't need any rcon nonsense with docker attach!

use `ctrl+p` then `ctrl+q` to quit.

`docker attach mcpe1`

**exec into the container's bash console**

`docker exec mcpe1 bash`


**NOTE**: referencing containers by name is only possible if you specify the `--name` flag in your docker run command.


## Set selinux context for mounted volumes

`chcon -Rt svirt_sandbox_file_t /path/to/volume`


## Server properties and environment variables

**Override the bedrock server version**

By default restarting the container will pull down the latest version.

However, you version pin your container. Use the following environment variable to do so.

To update, simply set the new version number and restart your container!

* `BEDROCK_VERSION=1.14.1.4`

**Set user and/or group id (optional)**
* `MINECRAFT_UID=1000`
* `MINECRAFT_GUID=1000`

### Template server.properties
Use [this file](https://github.com/japtain-cack/bedrock-server/blob/master/files/server.properties)
for the full server.properties reference.

This project uses [EnvForge config management](https://gitlab.com/envforge/envforge).
This allows for templatization of config files and options can be set using environment variables.
This allows for easier deployments using most docker orchestration/management platforms including Kubernetes.

The envforge template uses environment variables with the prefix `/minecraft/`. These map directly to environment variables where `/` becomes an underscore. For example, `/minecraft/server-name` maps to the environment variable `MINECRAFT_SERVER-NAME`.

Environment variables are processed as follows:
- `/minecraft/server-name` → `MINECRAFT_SERVER-NAME`
- `/minecraft/gamemode` → `MINECRAFT_GAMEMODE`
- `/minecraft/difficulty` → `MINECRAFT_DIFFICULTY`

So you can set:

```bash
docker run -e MINECRAFT_SERVER-NAME="My Awesome Server" \
           -e MINECRAFT_GAMEMODE=creative \
           -e MINECRAFT_DIFFICULTY=hard \
           nsnow/bedrock-server:latest
```

### Available Configuration Options

Common server.properties options that can be configured via environment variables:

- `MINECRAFT_SERVER-NAME` - Server display name
- `MINECRAFT_GAMEMODE` - Game mode (survival/creative/adventure)
- `MINECRAFT_DIFFICULTY` - World difficulty (peaceful/easy/normal/hard)
- `MINECRAFT_MAX-PLAYERS` - Maximum number of players
- `MINECRAFT_ONLINE-MODE` - Xbox Live authentication (true/false)
- `MINECRAFT_ALLOW-CHEATS` - Enable cheats (true/false)
- `MINECRAFT_WHITE-LIST` - Enable whitelist (true/false)
- `MINECRAFT_SERVER-PORT` - Server port (default: 19132)
- `MINECRAFT_VIEW-DISTANCE` - View distance in chunks
- `MINECRAFT_LEVEL-NAME` - World name
- `MINECRAFT_LEVEL-SEED` - World seed
