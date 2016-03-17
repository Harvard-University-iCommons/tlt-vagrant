#!/bin/bash

usage="$(basename "$0") [-h] [-d name] [-p pw] -- create a postgres db and login user with supplied name and password

where:
    -h  show this help text
    -d  set the name of the database and user to create
    -p  set the password for the db user login
    -m  run the Django migration command, after activating the virtualenv"

db_name=''
password=''
migrate=false

while getopts ":d:p:mh" opt; do
  case "$opt" in
    h)
        echo "$usage"
        exit 0
        ;;
    d)  db_name=$OPTARG  ;;
    p)  password=$OPTARG  ;;
    m)  migrate=true  ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
  esac
done

shift "$((OPTIND-1))" # Shift off the options and optional --.

if [[ -z "${db_name// }" ]] || [[ -z "${password// }" ]]
then
    echo "You must specify values for both -d and -p"
    exit 1
fi

# Run the psql commands
echo "Drop db $db_name, if exists"
psql -d postgres -c "DROP DATABASE IF EXISTS $db_name"

echo "Dropping user $db_name, if exists"
psql -d postgres -c "DROP USER IF EXISTS $db_name"

echo "Create user $db_name with password '$password'"
psql -d postgres -c "CREATE USER $db_name WITH PASSWORD '$password' CREATEDB"

echo "Create db $db_name with owner $db_name"
psql -d postgres -c "CREATE DATABASE $db_name WITH OWNER $db_name"

if $migrate
then
    source `which virtualenvwrapper.sh`
    workon $db_name
    python manage.py migrate
    deactivate
fi
