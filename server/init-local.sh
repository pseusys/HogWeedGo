#!/bin/bash

# Functions

function help () {
  echo "Run './start-local.sh CONFIG [ARGS]' where:"
  echo "    'CONFIG' is a path to user config file (required!)"
  echo "    if 'ARGS' is specified it will be executed after './manage.py ...', if not service initialization will be performed"
  echo "    if none is specified, this message will be displayed"
  exit 0
}

function print_error () {
  echo -e "\u001b[1m\u001b[31m$1\u001b[0m"
  exit 1
}

function handle_cancel () {
  echo "Ctrl-C caught, stopping service"
  unset PIPENV_QUIET
  while IFS='=' read -r key value; do unset "$key"; done <<< "$config"
  echo "Environmental variables from '$1' cleared"
  exit 2
}


# Settings and checks

trap 'handle_cancel $1' SIGINT
set -e

[ $# -eq 0 ] && help
[ -r "$1" ] || print_error "The first argument ($1) is not a valid user config file!"
config=$(sed -e 's/[[:space:]]*#.*// ; /^[[:space:]]*$/d' "$1")


# Script body

echo "Set environmental variables from '$1'"
while IFS='=' read -r key value; do export "$key"="$value"; done <<< "$config"

if [ $# -eq 1 ]; then
  echo "Check Python3 availability"
  [ "$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')" == '3.10' ] || print_error "Python 3.10 appears not to be installed, visit following link for installation guide: https://www.python.org/downloads/release/python-3100"
  psql --version > /dev/null || print_error "PostgreSQL appears not to be installed run following command to fix this: 'apt install postgresql-13 postgresql-client-13 postgresql-contrib postgis postgresql-13-postgis-3 gdal-bin"
  echo "Check PostgreSQL availability for user $POSTGRES_ADMIN"
  sudo sudo su - "$POSTGRES_ADMIN" && psql -c "" || print_error "Current user is not an administrator for PostgreSQL or has a password. Remove admin password (if any) and run the script again with 'sudo -u admin ...'"

  echo "Create PostgreSQL user '$POSTGRES_USER'"
  sudo psql -U "$POSTGRES_ADMIN" -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"
  echo "Create PostgreSQL database '$POSTGRES_DB'"
  sudo psql -U "$POSTGRES_ADMIN" -c "CREATE DATABASE $POSTGRES_DB WITH OWNER $POSTGRES_USER ENCODING UTF8;"
  echo "Create PostGIS extension for database '$POSTGRES_DB' if not exists"
  sudo psql -U "$POSTGRES_ADMIN" -d "$POSTGRES_DB" -c "CREATE EXTENSION IF NOT EXISTS postgis;" &&
  echo "Restart PostgreSQL"
  service postgresql restart

  export PIPENV_QUIET='True'
  echo "Install Pipfile packages"
  [ -d ./.venv ] || mkdir ./.venv
  pip install pipenv
  pipenv install --skip-lock

  echo "Create database migrations"
  pipenv run python3 ./manage.py makemigrations HogWeedGo
  echo "Apply database migrations"
  pipenv run python3 ./manage.py migrate
  echo "Create superuser"
  pipenv run python3 ./manage.py admin -e "$DJANGO_SUPERUSER_EMAIL" -p "$DJANGO_SUPERUSER_PASSWORD"
  echo "Server initialized successfully, use: './init-local.sh CONFIG COMMANDS' to run server."

else
  pipenv run python3 ./manage.py "${@:2}"
fi