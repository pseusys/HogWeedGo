#!/bin/bash
mkdir bundled-server

# https://github.com/docker/compose/issues/7964
docker-compose -f docker/docker-compose.yml -f docker/docker-compose.production.yml --env-file=docker/.env.development config --no-interpolate > bundled-server/docker-compose.bundle.yml

cp config.env bundled-server
mv bundled-server/config.env bundled-server/user-config.env

cp docker/.env.development bundled-server
mv bundled-server/.env.development bundled-server/system-config.env

zip -r bundled-server.zip bundled-server
rm -rf bundled-server
