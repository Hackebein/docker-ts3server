#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

status () {
    NAME=$1
    STATUS=$2
    echo -e "$NAME\r\t\t\t\t  $STATUS"
}

rm -rf ts3server_*
touch .wait
echo -n "Prepare worker threads "
while read release; do
    if [[ ${release} == "#"* ]]; then
        skip=true
        echo -n "#"
        release=$(echo ${release} | cut -f2 -d'#')
    else
        skip=false
        echo -n "."
    fi
    version=$(echo ${release} | cut -f1 -d'|')
    sha256=$(echo ${release} | cut -f2 -d'|')
    url=$(echo ${release} | cut -f3 -d'|')

    (
        while [[ -f .wait ]]; do
            sleep 1
        done
        if [[ $skip == true ]]; then
            status "hackebein/ts3server:$version" "skipped"
        else
            url_esc=$(echo ${url} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
            file=teamspeak3-server.$(echo ${url} | rev | cut -f -2 -d'.' | rev)

            cp -a "components" "ts3server_$version"
            sed -e "s/__TS3SERVER_VERSION__/$version/g" \
                -e "s/__TS3SERVER_URL__/$url_esc/g" \
                -e "s/__TS3SERVER_ARCHIVE__/$file/g" \
                -e "s/__TS3SERVER_SHA256__/$sha256/g" \
                -i "ts3server_$version/Dockerfile"
            log=$(docker build --no-cache -t hackebein/ts3server:${version} "ts3server_$version")
            status=$?
            if [[ $status == 0 ]]; then
                status "hackebein/ts3server:$version" "OK"
            else
                log_file="build_$version.log"
                echo $log > $log_file
                status "hackebein/ts3server:$version" "FAIL (log: $log)"
            fi
        fi
    ) &
done < releases
echo " done"
rm .wait
wait
