#!/usr/bin/env bash
# Borrowed some snippets from AshDevFr/docker-spigot, thanks AshDevFr!

echo "MCPE_HOME: $MCPE_HOME"
echo "BRSRVDIR: $BRSRVDIR"

# Copy game files to working dir
cp -rf /tmp/${BRSRVDIR}/* ./ \
  && rm -rf /tmp/${BRSRVDIR} \

# Change owner to minecraft.
if [ "$SKIPCHMOD" != "true" ]; then
  sudo chown -R minecraft:minecraft $MCPE_HOME/
  sudo rm -fv /etc/sudoers.d/minecraft
else
  echo "SKIPCHMOD option enabled. If you have access issue with your files, disable it"
fi

# Some variables are mandatory.
if [ -z "$REV" ]; then
  echo "REV option not defined. Please specify the version of the minecraft bedrock server."
fi

function setServerProp {
  local prop=$1
  local var=$2
  if [ -n "$var" ]; then
    if [[ -n $(grep -E "^${prop}.*?" $MCPE_HOME/server.properties) ]]; then
      echo "Setting ${prop}=${var}"
      sed -i "/$prop\s*=/ c $prop=$var" $MCPE_HOME/server.properties
    else
      echo "Adding ${prop}=${var}"
      echo "${prop}=${var}" >> $MCPE_HOME/server.properties
    fi
  fi
}

if [ -f $MCPE_HOME/server.properties ]; then
  setServerProp "motd" "$MOTD"
  setServerProp "level-name" "$LEVEL"
  setServerProp "level-seed" "$SEED"
  setServerProp "pvp" "$PVP"
  setServerProp "view-distance" "$VDIST"
  setServerProp "op-permission-level" "$OPPERM"
  setServerProp "allow-nether" "$NETHER"
  setServerProp "allow-flight" "$FLY"
  setServerProp "max-build-height" "$MAXBHEIGHT"
  setServerProp "spawn-npcs" "$NPCS"
  setServerProp "white-list" "$WLIST"
  setServerProp "spawn-animals" "$ANIMALS"
  setServerProp "hardcore" "$HC"
  setServerProp "online-mode" "$ONLINE"
  setServerProp "resource-pack" "$RPACK"
  setServerProp "difficulty" "$DIFFICULTY"
  setServerProp "enable-command-block" "$CMDBLOCK"
  setServerProp "max-players" "$MAXPLAYERS"
  setServerProp "spawn-monsters" "$MONSTERS"
  setServerProp "generate-structures" "$STRUCTURES"
  setServerProp "spawn-protection" "$SPAWNPROTECTION"
  setServerProp "max-tick-time" "$MAX_TICK_TIME"
  setServerProp "max-world-size" "$MAX_WORLD_SIZE"
  setServerProp "resource-pack-sha1" "$RPACK_SHA1"
  setServerProp "network-compression-threshold" "$NETWORK_COMPRESSION_THRESHOLD"
  setServerProp "allow-cheats" "$CHEATS"
  setServerProp "server-name" "$SERVERNAME"
  setServerProp "server-port" "$PORT"
  setServerProp "server-portv6" "$PORTV6"

  if [ -n "$MODE" ]; then
    case ${MODE,,?} in
      0|1|2|3)
        ;;
      s*)
        MODE=0
        ;;
      c*)
        MODE=1
        ;;
      *)
        echo "ERROR: Invalid game mode: $MODE"
        exit 1
        ;;
    esac

    sed -i "/gamemode\s*=/ c gamemode=$MODE" $MCPE_HOME/server.properties
  fi
else
  echo
  echo "server.properties not found!"
  exit 1
fi

if [ -n "$OPS" -a ! -e $MCPE_HOME/ops.txt.converted ]; then
  echo $OPS | awk -v RS=, '{print}' > $MCPE_HOME/ops.txt
fi

./bedrock_server

echo "code: $?"

