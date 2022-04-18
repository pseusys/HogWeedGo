## HogWeed Server

#### Requires:
 - Docker
 - docker-compose > 2.0  
   See [this](https://docs.docker.com/compose/install) for installation instructions for your OS and [this](https://github.com/docker/compose/releases/latest) for latest releases info (tested for [v2.2.3](https://github.com/docker/compose/releases/tag/v2.2.3)).

#### Run using: 
 - Debug + build mode: `docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.development up --build`
 - Debug mode: `docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.development up`
 - Release mode: `docker-compose -f ./docker/docker-compose.yml --env-file=./docker/.env.production up`
 
### Launch server locally
1. Download `bundled-server.zip` artifact from releases section, open it and unpack, run shell console there
2. Run script `./config-generator [DOMAIN]`, where DOMAIN - is your server domain name
3. Run `docker-compose -f ./docker-compose.yml --env-file=./system-config.env up`
4. Enjoy your server!  
NB! All the generated `*config.env` files are safe to edit BEFORE the first server launch. After that you shouldn't be modified in any way.
NB! By default, server runs on HTTPS, redirecting all HTTP traffic there. Ports for HTTP and HTTPS can be found in `./system-config.env up`, make sure they are free and available to use!  
NB! HTTPS certificates stored in `./certificates` folder are auto-generated and self-signed. Feel free to replace them with trusted ones.  
NB! Superuser email and password for accessing admin website are stored in `./config.env` file (DJANGO_SUPERUSER_EMAIL and DJANGO_SUPERUSER_PASSWORD respectively).

HogWeed Server roadmap:
- [x] Server website
- [x] Server API
- [x] Server API testing (in docker and locally)
- [ ] Server settings (backup, logs, admin notifications)
- [ ] Languages + translation
- [ ] Different authentication methods and providers
