#!/bin/bash
set -e

mkdir bundled-server

cp docker/docker-compose.yml bundled-server
sed -i -e 's/\.\./\./g' bundled-server/docker-compose.yml

cp docker/nginx.conf.template bundled-server
cp config-generator.sh bundled-server

cp docker/.env.production bundled-server
mv bundled-server/.env.production bundled-server/system-config.env

zip -r bundled-server.zip bundled-server
rm -rf bundled-server
