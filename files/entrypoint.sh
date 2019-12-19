#!/usr/bin/env bash

export REMCO_HOME=/etc/remco
export REMCO_RESOURCE_DIR=${REMCO_HOME}/resources.d
export REMCO_TEMPLATE_DIR=${REMCO_HOME}/templates

sudo chown -R minecraft:minecraft ${MCPE_HOME}

# Noclobber copy JSON files to prevent overwriting existing configs
cp -nv /tmp/bedrock-server-${BEDROCK_VERSION}/*.json $MCPE_HOME/server/ \
  && rm -fv /tmp/bedrock-server-${BEDROCK_VERSION}/*.json

# Copy game files to working dir
cp -rfv /tmp/bedrock-server-${BEDROCK_VERSION}/* $MCPE_HOME/server/ \
  && sudo chmod +x $MCPE_HOME/server/bedrock_server \
  && rm -rf /tmp/bedrock-server-${BEDROCK_VERSION} \
  && sudo chown -R minecraft:minecraft $MCPE_HOME \
  && sudo rm -fv /etc/sudoers.d/minecraft

remco

cd $MCPE_HOME/server && ./bedrock_server

