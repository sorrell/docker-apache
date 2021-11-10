#!/usr/bin/env bash

set -e

idmod www-data "$USER_UID" "$USER_GID" || true

rm -f /var/run/apache2/apache2.pid

if [ -s "/bootstrap/bootstrap.sh" ]; then
    ./bootstrap/bootstrap.sh 
fi

if [ $# -ne 0 ]; then
    exec tini -- "$@"
fi
