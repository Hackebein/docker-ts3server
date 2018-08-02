#!/usr/bin/env bash
set -e

cd "$(dirname "$(readlink -f "$0")")"

rm -rf releases.new
while read release; do
    version=$(echo ${release} | cut -f1 -d'|' | sed 's/#//g')
    arch=$(echo ${release} | cut -f2 -d'|')
    sha256old=$(echo ${release} | cut -f3 -d'|')
    url=$(echo ${release} | cut -f4 -d'|')
    echo "${version}|${arch}|$(wget "$url" -qO - | sha256sum | cut -f1 -d' ')|${url}" >> releases.new
done < releases
mv releases.new releases