## Build issues: There is a TLS issue in the build pipe that results into a wrong `latest` tag. Please use tag `3.13.6` instead!

# What is TeamSpeak 3?

TeamSpeak is a proprietary voice-over-Internet Protocol (VoIP) application for audio communication between users on a chat channel, much like a telephone conference call. Users typically use headphones with a microphone. The client software connects to a TeamSpeak server of the user's choice, from which the user may join chat channels.

# Quick Start

## Basic

```
docker run \
    -e "TS3SERVER_LICENSE=accept" \
    -p 9987:9987/udp \
    -p 30033:30033 \
    -p 10011:10011 \
    hackebein/ts3server
```
# Environment

## Basic

### TS3SERVER_LICENSE
Default: view

Since: 3.1.0

> if set to "accept", the server will assume you have read and accepted the license it comes with. If this is set to "view", the ts3server will not start.

### TS3SERVER_QUERY_PASSWORD
Default: <random>

Since: 3.0.0

> Defines the server query admin password.

### TS3SERVER_DB_CLIENT_DAYS
Default: 90

Since: 3.0.0

> Defines how many days to keep unused client identities. Auto-pruning is triggered on every start and on every new month while the server is running.

## Custom Patches

### TS3SERVER_PATCH_ENABLE
Default: false

Since: 3.0.0

> If set to 'true', the server patch routine will be enabled.

### TS3SERVER_PATCH_BADGES_DISABLE
Default: false

Since: 3.0.9

> If set to 'true', the badges of other users are hidden.

### TS3SERVER_PATCH_GDPR_SAVE
Default: false

Since: 3.0.0

> If set to 'true', the server save less ip adresses to fulfill the General Data Protection Regulation (GDPR).

## database

### TS3SERVER_DB_PLUGIN
Default: ts3db_sqlite3

Since: 3.0.0

> Possible values: ts3db_sqlite3, ts3db_mariadb

### TS3SERVER_DB_SQL_CREATE_PATH
Default: create_sqlite

Since: 3.0.0

> Possible values: create_sqlite, create_mariadb

### TS3SERVER_DB_HOST
Default: 127.0.0.1

Since: 3.0.0

> The hostname or IP addresss of your MariaDB/MySQL server.

### TS3SERVER_DB_PORT
Default: 3306

Since: 3.0.0

> The TCP port of your MariaDB/MySQL server.

### TS3SERVER_DB_USER
Default: root

Since: 3.0.0

> The username used to authenticate with your MariaDB/MySQL server.

### TS3SERVER_DB_PASSWORD
Default:

Since: 3.0.0

> The password used to authenticate with your MariaDB/MySQL server.

### TS3SERVER_DB_NAME
Default: test

Since: 3.0.0

> The name of a database on your MariaDB/MySQL server. Note that this database must be created before the TeamSpeak Server is started. Please use 'utf8mb4' character encoding for the database.

### TS3SERVER_DB_LOG_DAYS
Default: 90

Since: 3.0.0

> Defines how many days to keep database log entries. Auto-pruning is triggered on every start and on every new month while the server is running.

### TS3SERVER_DB_LOGGING_DISBALE
Default: 1/true

Since: 3.0.0

## Advanced

### TS3SERVER_CRASHDUMPS
Default: crashdumps

Since: 3.6.0

> When the server crashes, a crashdump is created that may be send to teamspeak to help fixing the crash. The location where the crashdumps are saved too, can be changed with this parameter. This feature is currently not supported on FreeBSD and Alpine versions of the TeamSpeak Server.

### TS3SERVER_DB_CLEAR
Default: 0/false

Since: 3.0.0

> If set to "1/true", the server database will be cleared before starting up the server. This is mainly used for testing. Usually this parameter should not be specified, so all server settings will be restored when the server process is restarted.

### TS3SERVER_DB_CONNECTIONS
Default: 10

Since: 3.0.0

> The number of database connections used by the server. Please note that changing this value can have an affect on your servers performance. Possible values are 2-100.

### TS3SERVER_DB_PLUGINPARAMETER
Default: ts3db.ini

Since: 3.0.0

### TS3SERVER_DB_SOCKET
Default:

Since: 3.0.0

> The name of the Unix socket file to use, for connections made via a named pipe to a local server.

### TS3SERVER_DB_SQL_PATH
Default: sql

Since: 3.0.0

> The physical path where your SQL script files are located.

### TS3SERVER_DB_UPDATE_DISABLE
Default: 0/false

Since: 3.0.0

> If set to '1/true', new permissions will not be added to existing groups automatically. Note that this can break your server configuration if you do not update them manually.

### TS3SERVER_DB_WAITUNTILREADY
Default: 30

Since: 3.1.0

### TS3SERVER_FILETRANSFER_IP
Default: 0.0.0.0

Since: 3.0.0

> Comma separated IP list which the file transfers are bound to.

### TS3SERVER_HINTS
Default: 0/false

Since: 3.10.0

### TS3SERVER_FILETRANSFER_PORT
Default: 30033

Since: 3.0.0

> TCP Port opened for file transfers.

### TS3SERVER_LICENSE_PATH
Default:

Since: 3.0.0

The physical path where your license file is located.

### TS3SERVER_LOG_APPEND
Default: 0/false

Since: 3.0.1

> If set to '1/true', the server will not create a new logfile on every start. Instead, the log output will be appended to the previous logfile. The logfile name will only contain the ID of the virtual server.

### TS3SERVER_LOG_PATH
Default: logs

Since: 3.0.0

> The physical path where the server will create logfiles.

### TS3SERVER_LOG_QUERY_COMMANDS
Default: 1/true

Since: 3.0.0

> If set to '1/true', the server will log every ServerQuery command executed by clients. This can be useful while trying to diagnose several different issues.

### TS3SERVER_MACHINE_ID
Default:

Since: 3.0.0

> Optional name of this server process to identify a group of servers with the same ID. This can be useful when running multiple TeamSpeak Server instances on the same database. Please note that we strongly recommend that you do NOT run multiple server instances on the same SQLite database.

### TS3SERVER_PRINT_ENV
Default: false

Since: 3.0.0

> If set to 'true', shows the environment at the beginning.

### TS3SERVER_PROXY
Default:

Since: 3.3.0

> If set, the server will use the specified proxy to contact the accounting server over http.
>
> Supported formats are:
> * domainname:port
> * ipv4address:port
> * [ipv6address]:port

### TS3SERVER_QUERY_BLACKLIST
Default: query_ip_blacklist.txt

Since: 3.0.0

### TS3SERVER_QUERY_BRUTFORCECHECK_DISABLE
Default: 0/false

Since: 3.0.8

> If set to '1/true', the server will skip and bruteforce protection for whitelisted Ip addresses for the ServerQuery interface.

### TS3SERVER_QUERY_BUFFER
Default: 20

Since: 3.3.0

> Server Query connections have a combined maximum buffer size. When this limit is exceeded, the connection using the most memory is closed. The default is 20, which means the maximum amount of buffered data is 20 megabyte. The minimum is 1 megabyte. Make sure to only enter positive integer numbers here.

### TS3SERVER_QUERY_DOCS_PATH
Default: serverquerydocs/

Since: 3.3.0

> Physical location where the server is looking for the documents used for the help command in ServerQuery.

### TS3SERVER_QUERY_HTTP_ENABLE
Default: false

Since: 3.12.0

### TS3SERVER_QUERY_HTTP_IP
Default: 0.0.0.0

Since: 3.12.0

### TS3SERVER_QUERY_HTTP_PORT
Default: 10080

Since: 3.12.0

### TS3SERVER_QUERY_HTTPS_ENABLE
Default: false

Since: 3.12.0

### TS3SERVER_QUERY_HTTPS_IP
Default: 0.0.0.0

Since: 3.12.0

### TS3SERVER_QUERY_HTTPS_PORT
Default: 10443

Since: 3.12.0

### TS3SERVER_QUERY_RAW_ENABLE
Default: true

Since: 3.3.0

### TS3SERVER_QUERY_RAW_IP
Default: 0.0.0.0

Since: 3.0.0

### TS3SERVER_QUERY_RAW_PORT
Default: 10011

Since: 3.0.0

### TS3SERVER_QUERY_SSH_ENABLE
Default: false

Since: 3.3.0

### TS3SERVER_QUERY_SSH_IP
Default: 0.0.0.0

Since: 3.3.0

### TS3SERVER_QUERY_SSH_PORT
Default: 10022

Since: 3.3.0

### TS3SERVER_QUERY_SSH_RSA_HOST_KEY
Default: ssh_host_rsa_key

Since: 3.3.0

> The physical path to the ssh_host_rsa_key to be used by query. If it does not exist, it will be created when the server is starting up.

### TS3SERVER_QUERY_TIMEOUT
Default: 300

Since: 3.3.0

### TS3SERVER_QUERY_WHITELIST
Default: query_ip_whitelist.txt

Since: 3.0.0

### TS3SERVER_VOICE_DEFAULT_CREATE
Default: 1/true

Since: 3.0.0

> Normally one virtual server is created automatically when the TeamSpeak Server process is started. To disable this behavior, set this parameter to '0/false'. In this case you have to start virtual servers manually using the ServerQuery interface.

### TS3SERVER_VOICE_DEFAULT_PORT
Default: 9987

Since: 3.0.0

> UDP port open for clients to connect to. This port is used by the first virtual server, subsequently started virtual servers will open on increasing port numbers.

### TS3SERVER_VOICE_IP
Default: 0.0.0.0

Since: 3.0.0

> Comma separated IP list on which the server instance will listen for incoming voice connections.
