ARG TS3SERVER_ARCH

FROM hackebein/ts3server:builder AS builder
ARG TS3SERVER_URL
ARG TS3SERVER_ARCHIVE
ARG TS3SERVER_SHA256
RUN wget "${TS3SERVER_URL}" -O "/tmp/${TS3SERVER_ARCHIVE}" \
 && echo "${TS3SERVER_SHA256} */tmp/${TS3SERVER_ARCHIVE}" | sha256sum -c - \
 && tar -C /app --strip 1 -xvf "/tmp/${TS3SERVER_ARCHIVE}" \
 && rm -rf \
    	/app/CHANGELOG \
		/app/doc \
		/app/docs \
		/app/tsdns \
		/app/ts3server_minimal_runscript.sh

FROM hackebein/ts3server:${TS3SERVER_ARCH}
ARG UID=1000
ARG GID=1000
COPY --from=builder /app /app
RUN chown ${UID}:${GID} /app /app/*
USER ${UID}:${GID}
VOLUME \
    /app/files \
    /app/ts3server.sqlitedb \
    /app/ts3server.sqlitedb-shm \
    /app/ts3server.sqlitedb-wal