#!/bin/sh
set -eu
cd /app
if [ ! -s Geyser.jar ]; then
  apk add --no-cache curl
  curl -fsSL -o Geyser.jar \
    https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone
fi
exec java -Xms512M -Xmx1G -jar Geyser.jar
