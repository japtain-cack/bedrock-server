#!/usr/bin/env bash

export REMCO_HOME=/etc/remco
export REMCO_RESOURCE_DIR=${REMCO_HOME}/resources.d
export REMCO_TEMPLATE_DIR=${REMCO_HOME}/templates
export BEDROCK_CURRENT_VERSION=$(./get-version.sh)
export BEDROCK_VERSION=${BEDROCK_VERSION:-$BEDROCK_CURRENT_VERSION}

echo "Current bedrock version: $BEDROCK_CURRENT_VERSION"
echo "Bedrock server version set to: $BEDROCK_VERSION"
echo

sudo chown -R minecraft:minecraft ${MINECRAFT_HOME}

# Download and extract bedrock server package
echo "Downloading and extracting server package"
curl -s https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip --output ./bedrock-server-${BEDROCK_VERSION}.zip && \
  unzip -q ./bedrock-server-${BEDROCK_VERSION}.zip -d ./bedrock-server-${BEDROCK_VERSION} && \
  chown -R minecraft:minecraft ./bedrock-server-${BEDROCK_VERSION} && \
  rm -f ./bedrock-server-${BEDROCK_VERSION}.zip

# Noclobber copy JSON files to prevent overwriting existing configs
echo "Installing server files"
cp -nv ./bedrock-server-${BEDROCK_VERSION}/*.json $MINECRAFT_HOME/server/ \
  && rm -f ./bedrock-server-${BEDROCK_VERSION}/*.json

# Copy game files to working dir
cp -rf ./bedrock-server-${BEDROCK_VERSION}/* $MINECRAFT_HOME/server/ \
  && chmod +x $MINECRAFT_HOME/server/bedrock_server \
  && rm -rf ./bedrock-server-${BEDROCK_VERSION}

# Ensure permissions are set then remove sudo access
echo "Setting file permissions"
chown -R minecraft:minecraft $MINECRAFT_HOME \
  #&& sudo rm -fv /etc/sudoers.d/minecraft \

remco

cd $MINECRAFT_HOME/server && ./bedrock_server

