FROM alpine
ARG ADDITIONAL_DEPENDENCIES=libstdc++
MAINTAINER Lars Olzem <hackebein@gmail.com>

ARG TS3SERVER_VERSION=3.4.0
ARG TS3SERVER_ARCH=alpine
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/3.4.0/teamspeak3-server_linux_alpine-3.4.0.tar.bz2
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.bz2
ARG TS3SERVER_SHA256=e356d0013d7e894fd1ed91725f09525e39f077901f84b50ecad0f1e5ab4ad527

ENV TS3SERVER_VERSION=$TS3SERVER_VERSION
ENV TS3SERVER_ARCH=$TS3SERVER_ARCH
ENV LD_LIBRARY_PATH=.:./redist

COPY overload /tmp/overload

RUN apk add --update  --no-cache \
		bash \
		busybox-extras \
		ca-certificates \
		expect \
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
		/app/tsdns \
		/app/ts3server_minimal_runscript.sh

VOLUME /app/files /app/logs
WORKDIR /app

EXPOSE 9987/udp 30033 10011
ENTRYPOINT ["/app/ts3server_startscript.sh"]
