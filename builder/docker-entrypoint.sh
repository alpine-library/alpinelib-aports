#!/bin/sh
set -e

export APORT_REPO=${APORT_REPO:-"https://github.com/alpine-library/alpinelib-aports.git"}
echo APORT_REPO=${APORT_REPO}

chown abuild:abuild /repo
abuild-keygen

if [ "$1" = 'build' ]; then
	set --  gosu abuild sh /repo-build.sh "$2"
fi

exec "$@"
