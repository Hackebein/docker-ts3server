FROM frolvlad/alpine-glibc
ARG ADDITIONAL_DEPENDENCIES=
MAINTAINER Lars Olzem <hackebein@gmail.com>

ARG TS3SERVER_VERSION=3.0.5
ARG TS3SERVER_ARCH=amd64
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/3.0.5/teamspeak3-server_linux-amd64-3.0.5.tar.gz
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.gz
ARG TS3SERVER_SHA256=61f158d445262dc682676b17c86c36db2008b9e472401bd6409a6f8dde3d595a

ENV TS3SERVER_VERSION=$TS3SERVER_VERSION
ENV TS3SERVER_ARCH=$TS3SERVER_ARCH
ENV LD_LIBRARY_PATH=.:./redist

COPY overload /tmp/overload

RUN apk add --update  --no-cache \
		bash \
		ca-certificates \
		${ADDITIONAL_DEPENDENCIES} \
	&& apk add --update --no-cache --virtual .build-dependencies \
		tar \
		wget \
	&& cd /tmp \
	&& wget ${TS3SERVER_URL} -O /tmp/${TS3SERVER_ARCHIVE} \
	&& echo "${TS3SERVER_SHA256} *${TS3SERVER_ARCHIVE}" | sha256sum -c - \
	&& mkdir -p /app \
	&& cd /app \
	&& tar -C /app --strip 1 -xvf /tmp/${TS3SERVER_ARCHIVE} \
	&& apk del .build-dependencies \
	&& mv /tmp/overload/* /app/ \
	&& touch /app/ts3server.ini /app/ts3db.ini\
	&& chown 1000:1000 /app/* \
	&& chmod ug+x /app/ts3server_startscript.sh \
	&& rm -rf \
		/var/cache/apk/* \
		/tmp/${TS3SERVER_ARCHIVE} \
		/tmp/overload \
		/app/CHANGELOG \
		/app/doc \
		/app/docs \
		/app/serverquerydocs \
		/app/tsdns \
		/app/ts3server_minimal_runscript.sh

VOLUME /app/files /app/logs
WORKDIR /app

EXPOSE 9987/udp 30033 10011
ENTRYPOINT ["/app/ts3server_startscript.sh"]
