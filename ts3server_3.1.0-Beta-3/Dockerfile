FROM alpine
ARG TS3SERVER_VERSION=3.1.0-Beta-3
ARG TS3SERVER_ARCH=alpine
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/pre_releases/server/3.1.0-Beta-3/teamspeak3-server_linux_alpine-3.1.0.tar.bz2
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.bz2
ARG TS3SERVER_SHA256=8e3de7acac3ed0db4ec59e8290b0b9d9042558f45d75bc85c91dd375162aaf38

ENV TS3SERVER_VERSION=$TS3SERVER_VERSION
ENV TS3SERVER_ARCH=$TS3SERVER_ARCH
ENV LD_LIBRARY_PATH=.:./redist

COPY overload /tmp/overload

RUN apk add --update  --no-cache \
		bash \
		ca-certificates \
	&& apk add --update --no-cache --virtual .build-dependencies \
		bzip2 \
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
	&& chmod ugo+x /app/ts3server_startscript.sh \
	&& rm -rf \
		/var/cache/apk/* \
		/tmp/${TS3SERVER_ARCHIVE} \
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
