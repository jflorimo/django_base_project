#!/bin/bash

# Get the value of a variable set in the file `.env`
function get_env() {
    grep "^$1=" .env | sed "s/$1=//;s/\s*#.*//"
}

# Run a docker-compose command configured with the project and environment
function d-c() {
    project=$(basename $(pwd))
    env=$(get_env ENVIRONMENT | tr '[[:upper:]]' '[[:lower:]]')
    docker-compose -p ${project} -f compose/${env}.yml "$@"
}

case "$1" in
    "open")
        heroku open -a stockmarketstat
        ;;
	  "heroku-shell")
        heroku run bash -a stockmarketstat
        ;;
    "heroku")
        heroku ${@:2} -a stockmarketstat
        ;;

    "update")
        venv=/tmp/.$RANDOM
        python3 -m venv $venv
        source $venv/bin/activate
        pip3 install pip-tools
        pushd etc/requirements/
            pip-compile --upgrade --rebuild dev.in -o dev.txt --verbose
            pip-compile --upgrade --rebuild prod.in -o prod.txt --verbose
            # workaround https://github.com/jazzband/pip-tools/issues/823
            sudo chmod u+rw,g+r,o+r dev.txt prod.txt
        popd
        deactivate
        rm -rf $venv
        ;;

    "django")
        d-c exec django ./manage.py ${@:2}
        ;;

    "fmt")
        d-c exec django black .
        ;;

    "logs")
        shift
        d-c logs -f "$@"
        ;;

    "run")
        d-c stop -t 0
        d-c build
        d-c up -d
        ;;
esac
