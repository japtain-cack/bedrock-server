# bedrock-server
Run a bedrock server in a Docker container.

Now with automatic bedrock server updates and remco config management. Just restart the container.

[![Docker Automated build](https://img.shields.io/docker/automated/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Stars](https://img.shields.io/docker/stars/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server)
[![Docker Build Status](https://img.shields.io/docker/build/nsnow/bedrock-server.svg)](https://hub.docker.com/r/nsnow/bedrock-server/builds)


This Dockerfile will download the Bedrock Server app and set it up, along with its dependencies.

If you run the container as is, the `worlds` directory will be created inside the container, which is inadvisable.
It is highly recommended that you store your worlds outside the container using a mount (see the example below).
Ensure that your file system permissions are correct, `chown 1000:1000 mount/path`, or modify the UID/GUID variables as needed (see below).

It is also likely that you will want to customize your `server.properties` file.
To do this, use the `-e <environment var>=<value>` for each setting in the `server.properties`.
The `server.properties` file will be overwritten every time the container is launched.


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
Use [this file](https://github.com/japtain-cack/bedrock-server/blob/master/remco/templates/server.properties)
for the full environment variable reference.
 
This project uses [Remco config management](https://github.com/HeavyHorst/remco).
This allows for templatization of config files and options can be set using environment variables.
This allows for easier deployments using most docker orchistration/management platforms including Kubernetes.

The remco tempate uses keys. This means you should see a string like `"/minecraft/some-option"` within the `getv()` function.
This directly maps to a environment variable, the `/` becomes an underscore basically. The other value in the `getv()` function is the default value.
For instance, `"/minecraft/some-option"` will map to the environment variable `MINECRAFT_SOME-OPTION`.

`getv("/minecraft/some-option", "default-value")`

becomes

`docker run -e MINECRAFT_SOME-OPTION=my-value ...`

