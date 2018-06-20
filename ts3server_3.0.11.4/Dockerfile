FROM frolvlad/alpine-glibc
ARG ADDITIONAL_DEPENDENCIES=
ARG TS3SERVER_VERSION=3.0.11.4
ARG TS3SERVER_ARCH=amd64
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/3.0.11.4/teamspeak3-server_linux-amd64-3.0.11.4.tar.gz
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.gz
ARG TS3SERVER_SHA256=92123aff892740c88acc30a6e3e4df1615be44f9780acd396d663bac91323a40

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
