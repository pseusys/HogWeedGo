#!/bin/bash

mkdir bundled-server

cp docker/docker-compose.yml bundled-server
cp docker/default.conf.template bundled-server
cp config-generator.sh bundled-server

cp tests/sample-config.env bundled-server
mv bundled-server/sample-config.env bundled-server/sample-user-config.env

cp docker/.env.production bundled-server
mv bundled-server/.env.production bundled-server/system-config.env

zip -r bundled-server.zip bundled-server
rm -rf bundled-server
