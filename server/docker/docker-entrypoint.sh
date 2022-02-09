#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
  echo "Collect static files"
  python manage.py collectstatic --noinput

  echo "Create database migrations"
  python manage.py makemigrations HogWeedGo

  echo "Apply database migrations"
  python manage.py migrate

  echo "Create superuser"
  python manage.py admin -e "${DJANGO_SUPERUSER_EMAIL-admin@site.com}" -p "${DJANGO_SUPERUSER_PASSWORD-12345678}"

  echo "Check deployment environment"
  python manage.py check --deploy

  echo "Start server"
  daphne -b 0.0.0.0 -p "$HOGWEED_PORT" HogWeedGo.asgi:application
fi

exec "$@"
