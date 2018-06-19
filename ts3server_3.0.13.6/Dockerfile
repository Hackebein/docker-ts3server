FROM frolvlad/alpine-glibc
ARG TS3SERVER_VERSION=3.0.13.6
ARG TS3SERVER_ARCH=amd64
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/3.0.13.6/teamspeak3-server_linux_amd64-3.0.13.6.tar.bz2
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.bz2
ARG TS3SERVER_SHA256=19ccd8db5427758d972a864b70d4a1263ebb9628fcc42c3de75ba87de105d179

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
