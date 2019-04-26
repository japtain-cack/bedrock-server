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
  # Redrock server settings
  setServerProp "difficulty" "$DIFFICULTY"
  setServerProp "level-type" "$LEVELTYPE"
  setServerProp "server-name" "$SERVERNAME"
  setServerProp "max-players" "$MAXPLAYERS"
  setServerProp "server-port" "$PORT"
  setServerProp "server-portv6" "$PORTV6"
  setServerProp "level-name" "$LEVELNAME"
  setServerProp "level-seed" "$SEED"
  setServerProp "online-mode" "$ONLINEMODE"
  setServerProp "white-list" "$WHITELIST"
  setServerProp "allow-cheats" "$ALLOWCHEATS"
  setServerProp "view-distance" "$VIEWDISTANCE"
  setServerProp "player-idle-timeout" "$PLAYERIDLETIMEOUT"
  setServerProp "max-threads" "$MAXTHREADS"
  setServerProp "tick-distance" "$TICKDISTANCE"
  setServerProp "default-player-permission-level" "$DEFAULTPLAYERPERMLEVEL"
  setServerProp "texturepack-required" "$TEXTUREPACKREQUIRED"

  # Java server settings that may/may not be supported
  setServerProp "motd" "$MOTD"
  setServerProp "pvp" "$PVP"
  setServerProp "op-permission-level" "$OPPERMLEVEL"
  setServerProp "allow-nether" "$NETHER"
  setServerProp "allow-flight" "$FLY"
  setServerProp "max-build-height" "$MAXBUILDHEIGHT"
  setServerProp "spawn-npcs" "$NPCS"
  setServerProp "spawn-animals" "$ANIMALS"
  setServerProp "hardcore" "$HARDCORE"
  setServerProp "resource-pack" "$RESOURCEPACK"
  setServerProp "enable-command-block" "$CMDBLOCK"
  setServerProp "spawn-monsters" "$MONSTERS"
  setServerProp "generate-structures" "$STRUCTURES"
  setServerProp "spawn-protection" "$SPAWNPROTECTION"
  setServerProp "max-tick-time" "$MAXTICKTIME"
  setServerProp "max-world-size" "$MAXWORLDSIZE"
  setServerProp "resource-pack-sha1" "$RESOURCEPACKSHA1"
  setServerProp "network-compression-threshold" "$NETWORKCOMPRESSIONTHRESHOLD"

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

