
docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.development.yml --env-file=./docker/.env.development up --build

docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.production.yml --env-file=./docker/.env.development up

docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.production.yml --env-file=./docker/.env.development config --no-interpolate > docker-compose.bundle.yml
