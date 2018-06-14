#!/bin/sh

export LD_LIBRARY_PATH=".:./redist:$LD_LIBRARY_PATH"

D1=$(readlink -f "$0")
D2=$(dirname "${D1}")
cd "${D2}"

# patching
if [ -e ts3server.dist ]; then
	cp -a ts3server.dist ts3server
	rm ts3server.dist
fi
if [ "${TS3SERVER_PATCH_ENABLE}" = "true" ]; then
	cp -a ts3server ts3server.dist
	# Patch for disable badges
	if [ "${TS3SERVER_PATCH_BADGES_DISABLE}" = "true" ]; then
		sed -e 's/client_badges/client_BADGES/g' -i ts3server
	fi
fi

# execution
if [ -z "${TS3SERVER_QUERY_PASSWORD}" ]; then
	exec ./ts3server $@
else
	exec ./ts3server serveradmin_password=${TS3SERVER_QUERY_PASSWORD} $@
fi
