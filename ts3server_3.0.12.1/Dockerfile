FROM frolvlad/alpine-glibc

ARG TS3SERVER_VERSION=3.0.12.1
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/3.0.12.1/teamspeak3-server_linux_amd64-3.0.12.1.tar.bz2
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.bz2
ARG TS3SERVER_SHA256=99d1382e748fe2099d519592c65bc4923b58b70fec2091b09a47e0a4ab34ff33

ENV TS3SERVER_VERSION=$TS3SERVER_VERSION
ENV LD_LIBRARY_PATH=.:./redist

COPY ts3server_startscript.sh /tmp/ts3server_startscript.sh
COPY query_ip_whitelist.txt /tmp/query_ip_whitelist.txt

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
	&& mv /tmp/ts3server_startscript.sh /tmp/query_ip_whitelist.txt /app/ \
    && chown root:root /app/* \
	&& touch /app/ts3server.ini /app/ts3db.ini\
    && chown 1000:1000 /app/* \
	&& chmod ugo+x /app/ts3server_startscript.sh \
	&& rm -rf \
	    /var/cache/apk/* \
		/tmp/${TS3SERVER_ARCHIVE} \
		/app/CHANGELOG \
		/app/doc \
		/app/docs \
		/app/redist \
		/app/serverquerydocs \
		/app/tsdns \
		/app/ts3server_minimal_runscript.sh \

EXPOSE 9987/udp 30033 10011

ENTRYPOINT ["/app/ts3server_startscript.sh"]
