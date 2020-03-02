"""
Django settings for project project.
"""

import environ
from pathlib import Path


# Load operating system environment variables and then prepare to use them
env = environ.Env()
ENVIRONMENT = env.str("ENVIRONMENT", default="DEV")
IS_DEV = ENVIRONMENT.lower() == "dev"
current_dir = Path(__file__).parents[0]
config_path = current_dir / (ENVIRONMENT + ".py").lower()

try:
    BASE_DIR = Path(__file__).parents[3] / "aux/"
except IndexError:
    BASE_DIR = Path("../aux/")


# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = env.str("DJANGO_SECRET_KEY")


# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = env.str("DEBUG", default=False)


# Application definition

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "project.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "project.wsgi.application"


# Password validation
# https://docs.djangoproject.com/en/2.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",},
]


# Internationalization
# https://docs.djangoproject.com/en/2.2/topics/i18n/

LANGUAGE_CODE = "en-us"

TIME_ZONE = "UTC"

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
STATIC_URL = "/static/"
STATIC_ROOT = str(f"{BASE_DIR}/static")
MEDIA_URL = "/media/"
MEDIA_ROOT = str(f"{BASE_DIR}/media")
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

DEFAULT_FROM_EMAIL = env.str("DJANGO_EMAIL_DEFAULT_FROM")


# Celery
CELERY_BROKER_URL = env.str("CELERY_BROKER_URL")
CELERY_RESULT_BACKEND = env.str("CELERY_RESULT_BACKEND", CELERY_BROKER_URL)
