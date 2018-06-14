#!/bin/sh

export LD_LIBRARY_PATH=".:./redist:$LD_LIBRARY_PATH"

D1=$(readlink -f "$0")
D2=$(dirname "${D1}")
cd "${D2}"

if [ -z "${TS3_PATCH_BADGES_DISABLE}" ]; then
	sed -e 's/\o0client_badges\o0/\o0client_badxxx\o0/g' -i ts3server
fi

if [ -z "${TS3_QUERY_PASSWORD}" ]; then
	exec ./ts3server $@
else
	exec ./ts3server serveradmin_password=${TS3_QUERY_PASSWORD} $@
fi
