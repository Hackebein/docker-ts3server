FROM frolvlad/alpine-glibc

ARG TS_VERSION=3.2.0

RUN apk add --update \
		wget \
		bzip2 \
		ca-certificates \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /opt \
	&& wget http://dl.4players.de/ts/releases/$TS_VERSION/teamspeak3-server_linux_amd64-$TS_VERSION.tar.bz2 \
		-O /opt/teamspeak3-server_linux_amd64-$TS_VERSION.tar.bz2 \
	&& tar -C /opt -jxvf /opt/teamspeak3-server_linux_amd64-$TS_VERSION.tar.bz2 \
	&& rm /opt/teamspeak3-server_linux_amd64-$TS_VERSION.tar.bz2 \
	&& rm -rf \
		/opt/teamspeak3-server_linux_amd64/tsdns \
		/opt/teamspeak3-server_linux_amd64/ts3server_startscript.sh

COPY ts3server_minimal_runscript.sh /opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh

RUN chmod ugo+x \
	/opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh
	
EXPOSE 9987/udp 30033 10011

ENTRYPOINT ["/opt/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh"]