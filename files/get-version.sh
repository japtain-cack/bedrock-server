#!/bin/bash

reUrl='https://minecraft.azureedge.net/bin-linux/bedrock-server-(.*?).zip'
reVersion='(([0-9]+.?)+)'

data=$(curl -s https://www.minecraft.net/en-us/download/server/bedrock/)
url=$(echo $data | grep -ioE $reUrl)

version=$(echo $url | grep -ioE $reVersion)
version=${version:-$1}

echo ${version%.}

