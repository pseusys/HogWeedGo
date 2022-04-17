## HogWeed Server

#### Requires:
 - Docker
 - docker-compose > 2.0  
   See [this](https://docs.docker.com/compose/install) for installation instructions for your OS and [this](https://github.com/docker/compose/releases/latest) for latest releases info (tested for [v2.2.3](https://github.com/docker/compose/releases/tag/v2.2.3)).

#### Run using: 
 - Debug + build mode: `docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.development up --build`
 - Debug mode: `docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.development up`
 - Release mode: `docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.production up`
 
### Image will be published using GitHub

HogWeed Server roadmap:
- [x] Server website
- [x] Server API
- [ ] Server settings (backup, logs, admin notifications)
- [ ] Languages + translation
- [ ] Different authentication methods and providers
