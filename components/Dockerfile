FROM frolvlad/alpine-glibc

ARG TS3SERVER_VERSION=__TS3SERVER_VERSION__
ENV TS3SERVER_VERSION=$TS3SERVER_VERSION

RUN apk add --update \
		bash \
		bzip2 \
		ca-certificates \
		wget \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /opt \
	&& wget http://dl.4players.de/ts/releases/$TS3SERVER_VERSION/teamspeak3-server_linux_amd64-$TS3SERVER_VERSION.tar.bz2 \
		-O /opt/teamspeak3-server_linux_amd64.tar.bz2 \
	&& tar -C /opt -jxvf /opt/teamspeak3-server_linux_amd64.tar.bz2 \
	&& mv /opt/teamspeak3-server_linux_amd64 /opt/teamspeak3-server \
	&& ln -s /opt/teamspeak3-server /app \
	&& rm -rf \
		/opt/teamspeak3-server_linux_amd64.tar.bz2 \
		/app/docs \
		/app/serverquerydocs \
		/app/tsdns \
		/app/ts3server_startscript.sh

COPY ts3server_runscript.sh /app/ts3server_runscript.sh
COPY query_ip_whitelist.txt /app/query_ip_whitelist.txt

RUN chmod ugo+x /app/ts3server_runscript.sh
	
EXPOSE 9987/udp 30033 10011

ENTRYPOINT ["/opt/teamspeak3-server/ts3server_runscript.sh"]
