FROM alpine:latest
COPY overload /app
RUN apk add --update --no-cache \
		tar \
		wget \
 && cd /app \
 && chmod ug+x /app/ts3server_startscript.sh
