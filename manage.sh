#!/bin/bash

# Get the value of a variable set in the file `.env`
function get_env() {
    grep "^$1=" .env | sed "s/$1=//;s/\s*#.*//"
}

# Run a docker-compose command configured with the project and environment
function d-c() {
    project=$(basename $(pwd))
    env=$(get_env ENVIRONMENT | tr '[[:upper:]]' '[[:lower:]]')
    docker compose -p ${project} -f compose/${env}.yml "$@"
}

# Manage the creation of a release and hotfix branches
function git-flow() {
    right_branch="$2"
    prefix="$3"
    current_branch="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "$current_branch" != "$right_branch" ]]; then
        >&2 echo "You need to be on the \"$right_branch\" branch to make a $prefix."
        return 1
    fi
    file="$1"

    version=$(grep __version__ "$file" | sed 's/__version__ = "\(.*\)"/\1/')
    version=$(( $version + 1 ))

    if git diff-index --quiet HEAD -- ; then
        dirty=0
    else
        dirty=1
        git stash
    fi
    sed -i "s/__version__ = \".*\"/__version__ = \"$version\"/" "$file"

    echo "Enter the suffix part of the branch. A new branch named \"$prefix/suffix\" will be created. Or press enter to use the default name."
    echo -n "$prefix/v[$version]: "
    read -r suffix
    if [[ -z $suffix ]]; then
        suffix=v"$version"
    fi

    git checkout -b "$prefix/$suffix"
    sed -i "/^## \\[Unreleased\\]/a \
        ## [$version] - $(date +%F)" CHANGELOG.md
    sed -i '/^## \[Unreleased\]/G' CHANGELOG.md
    git add CHANGELOG.md $file
    git commit -m "Bump version to $version"
    if [[ $dirty == 1 ]]; then
        git stash pop
    fi
}

function release() {
    git-flow "$1" develop release
}

function hotfix() {
    git-flow "$1" master hotfix
}

case "$1" in
    "open")
        project=$(get_env HEROKU_PROJECT_NAME)
        heroku open -a project
        ;;
	  "heroku-shell")
	    project=$(get_env HEROKU_PROJECT_NAME)
        heroku run bash -a project
        ;;
    "heroku")
        project=$(get_env HEROKU_PROJECT_NAME)
        heroku ${@:2} -a project
        ;;

    "test")
        shift
        d-c exec django pytest --cov --no-cov-on-fail --cov-report=html --cov-branch --cov-fail-under=96 "$@"
        ;;

    "db")
        db_name=$(get_env POSTGRES_DB)
        user=$(get_env POSTGRES_USER)
        d-c exec postgres psql "$db_name" "$user"
        ;;

    "release")
        release src/project/settings/__init__.py
        ;;

    "hotfix")
        hotfix src/project/settings/__init__.py
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

    "startapp")
        shift
        appname=$1
        ./manage.sh django startapp "$appname"
        rm src/"$appname"/{tests,views}.py
        mkdir src/"$appname"/tests/
        touch src/"$appname"/tests/__init__.py
        echo "from project.tests.conftest import *" > src/"$appname"/tests/conftest.py
        echo "If you have models or templatetags, don't forget to add $appname to INSTALLED_APPS"
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
