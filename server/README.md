
docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.development.yml --env-file=./docker/.env.development up --build

docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.production.yml --env-file=./docker/.env.production up

docker-compose -f ./docker/docker-compose.yml -f ./docker/docker-compose.production.yml --env-file=./docker/.env.production config --no-interpolate > docker-compose.bundle.yml

WARNING! Requires docker-compose > 2.0 to run!
See [this](https://docs.docker.com/compose/install) for installation instructions for your OS and [this](https://github.com/docker/compose/releases/latest) for latest releases info (tested for [v2.2.3](https://github.com/docker/compose/releases/tag/v2.2.3)).

./manage.py generateschema --file ../hogweedgo.openapi.yml
