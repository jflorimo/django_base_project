#!/bin/bash

function runserver() {
    if [[ "$ENVIRONMENT" == "DEV" ]]; then
        ./manage.py runserver 0.0.0.0:4000
    else
        timeout=${GUNICORN_TIMEOUT:-30}
        gunicorn --pythonpath src project.wsgi -t $timeout --log-file -
    fi
}

case "$ENVIRONMENT" in
    "DEV")
        ./manage.py makemigrations
        ./manage.py migrate --noinput
        ./manage.py collectstatic --noinput
	      python3 create_superuser.py
        ;;

    "PROD")
        cd /app/src
        ./manage.py migrate --noinput
        ./manage.py collectstatic --noinput
	      python3 create_superuser.py
        ;;
esac
runserver
