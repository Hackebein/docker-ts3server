#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

rm -rf ts3server_*
while read release; do
    version=$(echo ${release} | cut -f1 -d'|')
    url=$(echo ${release} | cut -f2 -d'|')
    url_esc=$(echo ${url} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
    file=teamspeak3-server.$(echo ${url} | rev | cut -f -2 -d'.' | rev)

    echo -n "ts3server_$version \t"
    cp -a "components" "ts3server_$version"
    sed -e "s/__TS3SERVER_VERSION__/$version/g" \
        -e "s/__TS3SERVER_URL__/$url_esc/g" \
        -e "s/__TS3SERVER_ARCHIVE__/$file/g" \
        -i "ts3server_$version/Dockerfile"

    docker build --no-cache -q -t hackebein/ts3server:${version} "ts3server_$version"
done < releases