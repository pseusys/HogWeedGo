"""
Django settings for HogWeedGo project.
"""
import json
import os
from glob import glob
from pathlib import Path


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ["DJANGO_SECRET"]

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True if os.environ["ENV"] == 'development' else False

ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS").split(" ")
CSRF_TRUSTED_ORIGINS = [f'http://{host}:{os.environ["SERVER_PORT"]}' for host in ALLOWED_HOSTS]


# Application definition

INSTALLED_APPS = [
    'HogWeedGo.apps.HogWeedGoConfig',
    'HogWeedGo.apps.HogWeedGoAdminConfig',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.gis',
    'django.forms',
    'leaflet'
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'HogWeedGo.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

FORM_RENDERER = 'django.forms.renderers.TemplatesSetting'

WSGI_APPLICATION = 'HogWeedGo.wsgi.application'


# Database
# https://docs.djangoproject.com/en/3.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'HOST': 'postgres' if os.environ["DOCKER"] == 'True' else os.environ["POSTGRES_HOST"],
        'PORT': os.environ["POSTGRES_PORT"],
        'NAME': os.environ["POSTGRES_DB"],
        'USER': os.environ["POSTGRES_USER"],
        'PASSWORD': os.environ["POSTGRES_PASSWORD"]
    }
}


# Password validation
# https://docs.djangoproject.com/en/3.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'}
]

AUTH_USER_MODEL = 'HogWeedGo.User'

AUTHENTICATION_BACKENDS = ['HogWeedGo.backends.SimpleBackend']

# Internationalization
# https://docs.djangoproject.com/en/3.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.2/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'static'
STATICFILES_DIRS = [BASE_DIR / 'assets']

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
# https://docs.djangoproject.com/en/3.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

LEAFLET_CONFIG = {
    'DEFAULT_CENTER': (59.937500, 30.308611),
    'DEFAULT_ZOOM': 9,
    'MIN_ZOOM': 1
}

DEFAULT_FROM_EMAIL = os.environ["SERVER_EMAIL_ADDRESS"]
EMAIL_USE_TLS = os.environ["SERVER_EMAIL_TLS"]
EMAIL_HOST = os.environ["SERVER_EMAIL_HOST"]
EMAIL_PORT = os.environ["SERVER_EMAIL_PORT"]
EMAIL_HOST_USER = os.environ["SERVER_EMAIL_USER"]
EMAIL_HOST_PASSWORD = os.environ["SERVER_EMAIL_PASSWORD"]


if os.environ['DOCKER'] == 'True':
    GDAL_LIBRARY_PATH = glob('/usr/lib/libgdal.so.*')[0]
    GEOS_LIBRARY_PATH = glob('/usr/lib/libgeos_c.so.*')[0]
