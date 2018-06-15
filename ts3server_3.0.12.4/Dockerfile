FROM frolvlad/alpine-glibc

ARG TS3SERVER_VERSION=3.0.12.4
ARG TS3SERVER_URL=http://dl.4players.de/ts/releases/3.0.12.4/teamspeak3-server_linux_amd64-3.0.12.4.tar.bz2
ARG TS3SERVER_ARCHIVE=teamspeak3-server.tar.bz2

ENV TS3SERVER_VERSION=$TS3SERVER_VERSION

RUN apk add --update \
		bash \
		bzip2 \
		ca-certificates \
		tar \
		wget \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /opt/teamspeak3-server \
	&& wget ${TS3SERVER_URL} -O /opt/${TS3SERVER_ARCHIVE} \
	&& tar -C /opt/teamspeak3-server --strip 1 -xvf /opt/${TS3SERVER_ARCHIVE} \
	&& ln -s /opt/teamspeak3-server /app \
	&& rm -rf \
		/opt/${TS3SERVER_ARCHIVE} \
		/app/docs \
		/app/serverquerydocs \
		/app/tsdns \
		/app/ts3server_startscript.sh

COPY ts3server_runscript.sh /app/ts3server_runscript.sh
COPY query_ip_whitelist.txt /app/query_ip_whitelist.txt

RUN chmod ugo+x /app/ts3server_runscript.sh
	
EXPOSE 9987/udp 30033 10011

ENTRYPOINT ["/opt/teamspeak3-server/ts3server_runscript.sh"]
