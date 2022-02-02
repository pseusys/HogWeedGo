#!/bin/bash

mkdir bundled-server

# https://github.com/docker/compose/issues/7964
# docker-compose -f docker/docker-compose.yml -f docker/docker-compose.production.yml --env-file=docker/.env.development config --no-interpolate | sed 's/\.\./\./' > bundled-server/docker-compose.bundle.yml
cp docker/docker-compose.bundle.yml bundled-server

cp samples/sample_config.env bundled-server
mv bundled-server/sample_config.env bundled-server/user-config.env

cp docker/.env.development bundled-server
mv bundled-server/.env.development bundled-server/system-config.env

cp docker/default.conf.template bundled-server

zip -r bundled-server.zip bundled-server
rm -rf bundled-server
