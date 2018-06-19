#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

rm -rf ts3server_*
while read release; do
    version=$(echo ${release} | cut -f1 -d'|' | sed 's/#//g')
    arch=$(echo ${release} | cut -f2 -d'|')
    sha256old=$(echo ${release} | cut -f3 -d'|')
    url=$(echo ${release} | cut -f4 -d'|')
    wget "$url" -qO "$version"
    echo "${version}|${arch}|$(sha256sum "$version" | cut -f1 -d' ')|${url}"
    rm "$version"
done < releases
