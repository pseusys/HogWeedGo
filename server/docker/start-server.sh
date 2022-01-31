#!/bin/sh

echo "Collect static files"
python manage.py collectstatic --noinput

echo "Create database migrations"
python manage.py makemigrations HogWeedGo

echo "Apply database migrations"
python manage.py migrate

echo "Create superuser"
python manage.py createsuperuser --no-input

echo "Start server"
python manage.py runserver 0.0.0.0:$SERVER_PORT
