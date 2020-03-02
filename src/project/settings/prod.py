import dj_database_url

from .common import env


DEBUG = False

# Database
DATABASES = {"default": dj_database_url.config(conn_max_age=600, ssl_require=True)}

ALLOWED_HOSTS = env.str("DJANGO_ALLOWED_HOSTS").split()

