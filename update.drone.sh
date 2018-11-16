#!/bin/bash

# TODO: auto detect last version
DEFAULT_VERSION="3.5.0"

template_publish() {
	PREFIX="${1:- } "
	if [[ "$(vercomp ${TS3SERVER_VERSION} '3.1.0')" == "<" ]]; then
		DEFAULT_ARCH=linux_amd64
	else
		DEFAULT_ARCH=linux_alpine
	fi
	TAGS="${TS3SERVER_VERSION}${TS3SERVER_VERSION_EXTENSION}-${TS3SERVER_ARCH}"
	if [[ "${TS3SERVER_ARCH}" == "${DEFAULT_ARCH}" ]]; then
		TAGS="${TAGS}, ${TS3SERVER_VERSION}${TS3SERVER_VERSION_EXTENSION}"
		if [[ "${TS3SERVER_VERSION}" == "${DEFAULT_VERSION}" ]]; then
			TAGS="${TAGS}, latest${TS3SERVER_VERSION_EXTENSION}"
		fi
	fi
	cat <<EOF

# ${TS3SERVER_VERSION}${TS3SERVER_VERSION_EXTENSION} (${TS3SERVER_ARCH})
${PREFIX}${TS3SERVER_VERSION}${TS3SERVER_VERSION_EXTENSION}-${TS3SERVER_ARCH}:
${PREFIX}  image: plugins/docker
${PREFIX}  group: versions
${PREFIX}  repo: hackebein/ts3server
${PREFIX}  dockerfile: Dockerfile.${TS3SERVER_ARCH}
${PREFIX}  build_args:
${PREFIX}    - TS3SERVER_URL=${TS3SERVER_URL}
${PREFIX}    - TS3SERVER_ARCHIVE=${TS3SERVER_ARCHIVE}
${PREFIX}  tags: ${TAGS}
${PREFIX}  secrets: [ docker_username, docker_password ]
${PREFIX}  when:
${PREFIX}    branch: master
${PREFIX}    event: push
EOF
}

download_list() {
	if [[ ! -f "download.list" ]]; then
		rm download.list.tmp
		wget --spider --recursive --no-parent --level=inf –-delete-after --no-verbose http://dl.4players.de/ts/releases/ 2>&1 \
		| sed -n -u -e "s@.\+ URL: \([^ ]\+\) .\+@\1@p" -e "s/&/\&amp;/" \
		| grep -i teamspeak3-server > download.list.tmp
		rm -rf dl.4players.de
		mv download.list.tmp download.list
		
		# TODO: sort by release date?
		#| echo $() \
		#| sort \
		#| cut -d'|' -f2-
		#curl -I http://dl.4players.de/ts/releases/pre_releases/server/3.5.0-Beta-2/teamspeak3-server_win64-3.5.0.zip 2>&1
	fi
	cat "download.list"
}

vercomp () {
    if [[ $1 == $2 ]]; then
        echo "="
		return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            echo ">"
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
			echo "<"
            return
        fi
    done
	echo "="
	return
}

# build .drone.yml
echo "pipeline:" > .drone.yml
while read -r TS3SERVER_URL; do
	TS3SERVER_ARCHIVE=$(echo $TS3SERVER_URL | sed -n 's/.*\/\([^\/]\+\)$/\1/p')
	TS3SERVER_ARCH=$(echo $TS3SERVER_ARCHIVE | sed -n 's/teamspeak3-server_\([a-z0-9]\+\([-_][a-z0-9]\+\)\?\)-.*$/\1/p' | sed -e 's/-/_/g' -e "s/./\L&/g")
	TS3SERVER_VERSION=$(echo $TS3SERVER_URL | sed -n 's/.*\/\([0-9][^\/]\+\)\/.*/\1/p' | sed -e "s/./\L&/g" -e "s/-//2g")
	for filename in Dockerfile.${TS3SERVER_ARCH}*; do
		if [[ ! -f $filename ]]; then continue; fi
		TS3SERVER_VERSION_EXTENSION=$(echo $filename | sed -e "s/^Dockerfile.${TS3SERVER_ARCH}//g")
		printf "%-17s %-23s [%s]\n" "${TS3SERVER_VERSION}" "${TS3SERVER_ARCH}${TS3SERVER_VERSION_EXTENSION}" "${TS3SERVER_ARCHIVE}"
		echo "$(template_publish)" >> .drone.yml
	done
done < <(download_list)