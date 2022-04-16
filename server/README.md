docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.development build --no-cache
docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.production up --no-build

docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.development up --build

WARNING! Requires docker-compose > 2.0 to run!
See [this](https://docs.docker.com/compose/install) for installation instructions for your OS and [this](https://github.com/docker/compose/releases/latest) for latest releases info (tested for [v2.2.3](https://github.com/docker/compose/releases/tag/v2.2.3)).

HogWeed Server roadmap:
- [x] Server website
- [x] Server API
- [ ] Server settings (backup, logs, admin notifications)
- [ ] Languages + translation
- [ ] Different authentication methods and providers
