#!/bin/bash
ARCHS=()
ARCHS+=("linux_alpine")
 
cat > .drone.yml <<EOF
pipeline:
  builder:
    image: plugins/docker
    group: base
    repo: hackebein/ts3server
    dockerfile: Dockerfile.builder
    tags: builder
    secrets: [ docker_username, docker_password ]
    when:
      branch: master
      event: push

EOF
while read -r TS3SERVER_ARCH; do
	if [[ " ${ARCHS[@]} " =~ " ${TS3SERVER_ARCH} " ]]; then
	#if [[ -f Dockerfile.${TS3SERVER_ARCH} ]]; then
		#ARCHS+=("${TS3SERVER_ARCH}")
		cat >> .drone.yml <<EOF
  build-${TS3SERVER_ARCH}:
    image: plugins/docker
    group: base
    repo: hackebein/ts3server
    dockerfile: Dockerfile.${TS3SERVER_ARCH}
    tags: ${TS3SERVER_ARCH}
    secrets: [ docker_username, docker_password ]
    when:
      branch: master
      event: push

EOF
	else
		cat >> .drone.yml <<EOF
#  build-${TS3SERVER_ARCH}:
#    image: plugins/docker
#    group: base
#    repo: hackebein/ts3server
#    dockerfile: Dockerfile.${TS3SERVER_ARCH}
#    tags: ${TS3SERVER_ARCH}
#    secrets: [ docker_username, docker_password ]
#    when:
#      branch: master
#      event: push

EOF
	fi
done < <(find . -type f -name '*server*' ! -name '*steadyclock*' | rev | cut -d'/' -f1 | rev | cut -d'-' -f2- | rev | cut -d'-' -f2- | rev | cut -d'_' -f2- | sed -e 's/-/_/g' | sort -u)

while read -r FILEPATH; do
	TS3SERVER_ARCHIVE=$(echo $FILEPATH | rev | cut -d'/' -f1 | rev)
	TS3SERVER_VERSION_FOLDER=$(echo $FILEPATH | sed -e 's!^./!!g' -e 's!^pre_releases/server/!!g' | cut -d'/' -f1)
	TS3SERVER_VERSION_BASE=$(echo ${TS3SERVER_VERSION_FOLDER} | cut -d'-' -f1)
	TS3SERVER_VERSION_SUFFIX=$(echo ${TS3SERVER_VERSION_FOLDER,,} | cut -d'-' -f2- | sed -e 's/-//g')
	if [[ "${TS3SERVER_VERSION_BASE}" == "${TS3SERVER_VERSION_SUFFIX}" ]]; then
		TS3SERVER_VERSION=${TS3SERVER_VERSION_BASE}
	else
		TS3SERVER_VERSION=${TS3SERVER_VERSION_BASE}-${TS3SERVER_VERSION_SUFFIX}
	fi
	TS3SERVER_ARCH=$(echo $TS3SERVER_ARCHIVE | cut -d'-' -f2- | rev | cut -d'-' -f2- | rev | cut -d'_' -f2- | sed -e 's/-/_/g')
	printf "%-12s %-13s [%s]\n" "${TS3SERVER_VERSION}" "${TS3SERVER_ARCH}" "$FILEPATH"
	TS3SERVER_URL="http://dl.4players.de/ts/releases/$(echo $FILEPATH | cut -d'/' -f2-)"
	TS3SERVER_SHA256=$(sha256sum $FILEPATH | cut -d' ' -f1)
	if [[ "${TS3SERVER_ARCH}" == "linux_alpine" ]]; then
		TAGS="${TS3SERVER_ARCH}-${TS3SERVER_VERSION}, ${TS3SERVER_VERSION}"
	else
		TAGS="${TS3SERVER_ARCH}-${TS3SERVER_VERSION}"
	fi
	if [[ " ${ARCHS[@]} " =~ " ${TS3SERVER_ARCH} " ]]; then
		cat >> .drone.yml <<EOF
  publish-${TS3SERVER_VERSION}-${TS3SERVER_ARCH}:
    image: plugins/docker
    group: versions
    repo: hackebein/ts3server
    dockerfile: Dockerfile
    build_args:
      - TS3SERVER_VERSION=${TS3SERVER_VERSION}
      - TS3SERVER_ARCH=${TS3SERVER_ARCH}
      - TS3SERVER_URL=${TS3SERVER_URL}
      - TS3SERVER_ARCHIVE=${TS3SERVER_ARCHIVE}
      - TS3SERVER_SHA256=${TS3SERVER_SHA256}
    tags: ${TAGS}
    secrets: [ docker_username, docker_password ]
    when:
      branch: master
      event: push

EOF
	else
		cat >> .drone.yml <<EOF
#  publish-${TS3SERVER_VERSION}-${TS3SERVER_ARCH}:
#    image: plugins/docker
#    group: versions
#    repo: hackebein/ts3server
#    dockerfile: Dockerfile
#    build_args:
#      - TS3SERVER_VERSION=${TS3SERVER_VERSION}
#      - TS3SERVER_ARCH=${TS3SERVER_ARCH}
#      - TS3SERVER_URL=${TS3SERVER_URL}
#      - TS3SERVER_ARCHIVE=${TS3SERVER_ARCHIVE}
#      - TS3SERVER_SHA256=${TS3SERVER_SHA256}
#    tags: ${TAGS}
#    secrets: [ docker_username, docker_password ]
#    when:
#      branch: master
#      event: push

EOF
	fi
done < <(find . -type f -name '*server*' ! -name '*steadyclock*' -printf "%T+|%p\n" | sort | cut -d'|' -f2-)