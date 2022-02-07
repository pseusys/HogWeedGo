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
SECRET_KEY = os.environ['DJANGO_SECRET']

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True if os.getenv('ENV', 'development') == 'development' else False
DOCKER = True if os.getenv('DOCKER', 'False') == 'True' else False

ALLOWED_HOSTS = ['::1', '127.0.0.1', 'localhost'] + os.getenv('DJANGO_HOST', "").split(" ")
CSRF_TRUSTED_ORIGINS = [f"http://{host}:{os.getenv('SERVER_PORT', 3000)}" for host in ALLOWED_HOSTS]


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
    'rest_framework',
    'rest_framework.authtoken',
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
        'HOST': 'postgres' if DOCKER else os.environ["POSTGRES_HOST"],
        'PORT': os.getenv('POSTGRES_PORT', 5432),
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

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticatedOrReadOnly'
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication'
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'user': '4/minute'
    }
}

DEFAULT_FROM_EMAIL = f'no-reply@{ALLOWED_HOSTS[-1]}'
EMAIL_HOST = 'mail-agent'
EMAIL_PORT = 25


if DOCKER:
    GDAL_LIBRARY_PATH = glob('/usr/lib/libgdal.so.*')[0]
    GEOS_LIBRARY_PATH = glob('/usr/lib/libgeos_c.so.*')[0]
