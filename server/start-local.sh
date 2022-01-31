#!/bin/bash

env $(cat config.env | xargs) rails

env DOCKER=False
env ENV=development
env POSTGRES_PORT=5432
env POSTGRES_HOST=localhost

#pip install Pillow psycopg2-binary django django-leaflet
#sudo apt install gdal-bin postgresql postgis postgresql-postgis

#sudo -u postgres psql
#CREATE USER admin WITH PASSWORD '12345';
#CREATE DATABASE hogweedgo WITH OWNER admin ENCODING UTF8;
#sudo -u postgres psql -d hogweedgo -c "CREATE EXTENSION IF NOT EXISTS postgis;"

#psql -U admin -h 127.0.0.1 hogweedgo

#python manage.py createsuperuser

#static

#db
#test

#daphne -b 0.0.0.0 -p 8000 sse_demo.asgi:application or runserver
#navigate to /admin/
