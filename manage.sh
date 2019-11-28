#!/bin/bash

case "$1" in
    "open")
        heroku open -a stockmarketstat
        ;;

    "django")
        python src/manage.py ${@:2}
        ;;

    "run")
        python src/manage.py runserver
        ;;
esac