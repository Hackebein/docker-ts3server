#!/usr/bin/env bash
set -eu
cd "$(dirname "$(readlink -f "$0")")"

# vercomp '3.0.0' '3.1.0'
# case $? in
	# 0) foo='=';;
	# 1) foo='>';;
	# 2) foo='<';;
# esac
vercomp () {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

vercompare () {
	vercomp $1 $3
	case $? in
		0) op='=';;
		1) op='>';;
		2) op='<';;
	esac

	if [[ $2 = *"${op}"*  ]]; then
		echo true
	else
		echo false
	fi
}

# environment
export LD_LIBRARY_PATH="/usr/local/lib"
export TS3SERVER_VERSION=${TS3SERVER_VERSION:-0}
export TS3SERVER_LICENSEPATH=${TS3SERVER_LICENSEPATH:-}
export TS3SERVER_IP_WHITELIST=${TS3SERVER_IP_WHITELIST:-query_ip_whitelist.txt}
export TS3SERVER_IP_BLACKLIST=${TS3SERVER_IP_BLACKLIST:-query_ip_blacklist.txt}
export TS3SERVER_LOG_PATH=${TS3SERVER_LOG_PATH:-/app/logs}
export TS3SERVER_LOG_QUERY_COMMANDS=${TS3SERVER_LOG_QUERY_COMMANDS:-0}
export TS3SERVER_LOG_APPEND=${TS3SERVER_LOG_APPEND:-0}
export TS3SERVER_DB_PLUGIN=${TS3SERVER_DB_PLUGIN:-ts3db_sqlite3}
export TS3SERVER_DB_PLUGINPARAMETER=${TS3SERVER_DB_PLUGINPARAMETER:-/app/ts3db.ini}
export TS3SERVER_DB_SQLPATH=${TS3SERVER_DB_SQLPATH:-/app/sql/}
export TS3SERVER_DB_SQLCREATEPATH=${TS3SERVER_DB_SQLCREATEPATH:-create_sqlite}
export TS3SERVER_DB_CONNECTIONS=${TS3SERVER_DB_CONNECTIONS:-10}
export TS3SERVER_DB_CLIENTKEEPDAYS=${TS3SERVER_DB_CLIENTKEEPDAYS:-30}
export TS3SERVER_DB_HOST=${TS3SERVER_DB_HOST:-}
export TS3SERVER_DB_PORT=${TS3SERVER_DB_PORT:-3306}
export TS3SERVER_DB_USER=${TS3SERVER_DB_USER:-}
export TS3SERVER_DB_PASSWORD=${TS3SERVER_DB_PASSWORD:-}
export TS3SERVER_DB_NAME=${TS3SERVER_DB_NAME:-}
export TS3SERVER_DB_SOCKET=${TS3SERVER_DB_SOCKET:-}
export TS3SERVER_DB_WAITUNTILREADY=${TS3SERVER_DB_WAITUNTILREADY:-30}
export TS3SERVER_QUERY_PASSWORD=${TS3SERVER_QUERY_PASSWORD:-}
export TS3SERVER_PATCH_ENABLE=${TS3SERVER_PATCH_ENABLE:-false}
export TS3SERVER_PATCH_BADGES_DISABLE=${TS3SERVER_PATCH_BADGES_DISABLE:-false}
export TS3SERVER_SUPPORT_BADGE=$(vercompare ${TS3SERVER_VERSION} '>=' '3.0.9')

if [[ ${TS3SERVER_SUPPORT_BADGE} != true ]]; then
	TS3SERVER_PATCH_BADGES_DISABLE=false
fi

echo ---
printenv | grep '^TS3SERVER_' | grep -v 'PASSWORD' | sort
echo ---

# main
if [ -e ts3server.dist ]; then
	cp -a ts3server.dist ts3server
	rm ts3server.dist
fi
if [[ "${TS3SERVER_PATCH_ENABLE}" == "true" ]]; then
	cp -a ts3server ts3server.dist
	# Patch for disable badges
	if [[ "${TS3SERVER_PATCH_BADGES_DISABLE}" == "true" ]]; then
		sed -e 's/client_badges/client_BADGES/g' -i ts3server
	fi
fi

# TODO: cmd param
# query_port=10011
# filetransfer_ip=0.0.0.0 # do also if port only is set!
# filetransfer_port=30033

cat <<- EOF >/app/ts3server.ini
    licensepath=${TS3SERVER_LICENSEPATH}
    query_ip_whitelist=${TS3SERVER_IP_WHITELIST}
    query_ip_blacklist=${TS3SERVER_IP_BLACKLIST}
    dbplugin=${TS3SERVER_DB_PLUGIN}
    dbpluginparameter=${TS3SERVER_DB_PLUGINPARAMETER}
    dbsqlpath=${TS3SERVER_DB_SQLPATH}
    dbsqlcreatepath=${TS3SERVER_DB_SQLCREATEPATH}
    dbconnections=${TS3SERVER_DB_CONNECTIONS}
    dbclientkeepdays=${TS3SERVER_DB_CLIENTKEEPDAYS}
    logpath=${TS3SERVER_LOG_PATH}
    logquerycommands=${TS3SERVER_LOG_QUERY_COMMANDS}
    logappend=${TS3SERVER_LOG_APPEND}
EOF
cat <<- EOF >/app/ts3db.ini
    [config]
    host='${TS3SERVER_DB_HOST}'
    port='${TS3SERVER_DB_PORT}'
    username='${TS3SERVER_DB_USER}'
    password='${TS3SERVER_DB_PASSWORD}'
    database='${TS3SERVER_DB_NAME}'
    socket=${TS3SERVER_DB_SOCKET}
    wait_until_ready='${TS3SERVER_DB_WAITUNTILREADY}'
EOF

# prepare execution
set -- "$@" inifile=/var/run/ts3server/ts3server.ini
if [ -n "${TS3SERVER_QUERY_PASSWORD}" ]; then
    set -- "$@" serveradmin_password=${TS3SERVER_QUERY_PASSWORD}
fi

# execution
exec ./ts3server "$@"
