#!/bin/sh
set -e

export APORT_REPO=${APORT_REPO:-"https://github.com/alpine-library/alpinelib-aports.git"}
echo APORT_REPO=${ELASTICSEARCH_URL}

if [ "$1" = 'build' ]; then
	set -- /repo-build.sh "$@"
fi

exec "$@"
