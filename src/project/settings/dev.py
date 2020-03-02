import socket

from .common import BASE_DIR, INSTALLED_APPS, env

DEBUG = True


def docker_ip():
    hostname = socket.gethostname()
    return socket.gethostbyname(hostname)


# Database
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "NAME": env.str("POSTGRES_DB"),
        "USER": env.str("POSTGRES_USER"),
        "PASSWORD": env.str("POSTGRES_PASSWORD"),
        "HOST": env.str("POSTGRES_HOSTNAME"),
        "PORT": env.str("POSTGRES_PORT"),
    }
}


# Set this to allow the use of a dev instance from it's external IP.
EXTERNAL_IP = env.str("EXTERNAL_IP")
ALLOWED_HOSTS = ["127.0.0.1", "localhost", docker_ip(), EXTERNAL_IP] + env.str(
    "DJANGO_ALLOWED_HOSTS"
).split()

INSTALLED_APPS += []

EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend"
EMAIL_FILE_PATH = str(BASE_DIR / "received_emails/")

CELERY_TASK_ALWAYS_EAGER = True
