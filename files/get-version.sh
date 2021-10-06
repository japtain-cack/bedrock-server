#!/bin/bash

reUrl='https://minecraft.azureedge.net/bin-linux/bedrock-server-(.*?).zip'
reVersion='(([0-9]+.?)+)'

data=$(curl -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" -sL https://www.minecraft.net/en-us/download/server/bedrock/)
url=$(echo $data | grep -ioE $reUrl)

version=$(echo $url | grep -ioE $reVersion)
version=${version:-$1}

echo ${version%.}

