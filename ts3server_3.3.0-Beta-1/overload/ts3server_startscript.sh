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

trailingslash () {
  if [[ $1 == *"/" ]]; then
    echo $1
  else
    echo $1/
  fi
}

# environment
# since 3.0.0
export TS3SERVER_DB_CLEAR=${TS3SERVER_DB_CLEAR:-0}
# since 3.0.0
export TS3SERVER_DB_CLIENT_DAYS=${TS3SERVER_DB_CLIENT_DAYS:-90}
# since 3.0.0
export TS3SERVER_DB_CONNECTIONS=${TS3SERVER_DB_CONNECTIONS:-10}
# since 3.0.0
export TS3SERVER_DB_HOST=${TS3SERVER_DB_HOST:-127.0.0.1}
# since 3.0.0
export TS3SERVER_DB_LOG_DAYS=${TS3SERVER_DB_LOG_DAYS:-90}
# since 3.0.0
export TS3SERVER_DB_LOGGING_DISBALE=${TS3SERVER_DB_LOGGING_DISBALE:-1}
# since 3.0.0
export TS3SERVER_DB_NAME=${TS3SERVER_DB_NAME:-test}
# since 3.0.0
export TS3SERVER_DB_PASSWORD=${TS3SERVER_DB_PASSWORD:-}
# since 3.0.0
export TS3SERVER_DB_PLUGIN=${TS3SERVER_DB_PLUGIN:-ts3db_sqlite3}
# since 3.0.0
# TODO:ts3db_mariadb is auto loaded?
export TS3SERVER_DB_PLUGINPARAMETER=${TS3SERVER_DB_PLUGINPARAMETER:-ts3db.ini}
# since 3.0.0
export TS3SERVER_DB_PORT=${TS3SERVER_DB_PORT:-3306}
# since 3.0.0
export TS3SERVER_DB_SOCKET=${TS3SERVER_DB_SOCKET:-}
# since 3.0.0
export TS3SERVER_DB_SQL_CREATE_PATH=${TS3SERVER_DB_SQLCREATEPATH:-create_sqlite}
# since 3.0.0
export TS3SERVER_DB_SQL_PATH=${TS3SERVER_DB_SQLPATH:-sql}
# since 3.0.0
export TS3SERVER_DB_UPDATE_DISABLE=${TS3SERVER_DB_UPDATE_DISABLE:-0}
# since 3.0.0
export TS3SERVER_DB_USER=${TS3SERVER_DB_USER:-root}
# since 3.1.0
export TS3SERVER_DB_WAITUNTILREADY=${TS3SERVER_DB_WAITUNTILREADY:-30}
# since 3.0.0
export TS3SERVER_FILETRANSFER_IP=${TS3SERVER_FILETRANSFER_IP:-0.0.0.0}
# since 3.0.0
export TS3SERVER_FILETRANSFER_PORT=${TS3SERVER_FILETRANSFER_PORT:-30033}
# since 
export TS3SERVER_LICENSE=${TS3SERVER_LICENSE:-view}
# since 3.0.0
export TS3SERVER_LICENSE_PATH=${TS3SERVER_LICENSEPATH:-}
# since 3.0.1
export TS3SERVER_LOG_APPEND=${TS3SERVER_LOG_APPEND:-0}
# since 3.0.0
export TS3SERVER_LOG_PATH=${TS3SERVER_LOG_PATH:-logs}
# since 3.0.0
export TS3SERVER_LOG_QUERY_COMMANDS=${TS3SERVER_LOG_QUERY_COMMANDS:-1}
# since 3.0.0
export TS3SERVER_MACHINE_ID=${TS3SERVER_MACHINE_ID:-}
# since 3.0.9
export TS3SERVER_PATCH_BADGES_DISABLE=${TS3SERVER_PATCH_BADGES_DISABLE:-false}
# since 3.0.0
export TS3SERVER_PATCH_ENABLE=${TS3SERVER_PATCH_ENABLE:-false}
# since 3.0.0
export TS3SERVER_PATCH_GDPR_SAVE=${TS3SERVER_PATCH_GDPR_SAVE:-false}
# since 3.0.0
export TS3SERVER_PRINT_ENV=${TS3SERVER_PRINT_ENV:-false}
# since 3.3.0
export TS3SERVER_PROXY=${TS3SERVER_PROXY:-}
# since 3.0.0
export TS3SERVER_QUERY_BLACKLIST=${TS3SERVER_QUERY_BLACKLIST:-query_ip_blacklist.txt}
# since 3.0.8
export TS3SERVER_QUERY_BRUTFORCECHECK_DISABLE=${TS3SERVER_QUERY_BRUTFORCECHECK_DISABLE:-0}
# since 3.3.0
export TS3SERVER_QUERY_BUFFER=${TS3SERVER_QUERY_BUFFER:-20}
# since 3.3.0
export TS3SERVER_QUERY_DOCS_PATH=${TS3SERVER_QUERY_DOCS_PATH:-serverquerydocs/}
# since 3.0.0
export TS3SERVER_QUERY_IP=${TS3SERVER_QUERY_IP:-0.0.0.0}
# since 3.0.0
export TS3SERVER_QUERY_PASSWORD=${TS3SERVER_QUERY_PASSWORD:-}
# since 3.0.0
export TS3SERVER_QUERY_PORT=${TS3SERVER_QUERY_PORT:-10011}
# since 3.0.0
export TS3SERVER_QUERY_WHITELIST=${TS3SERVER_QUERY_WHITELIST:-query_ip_whitelist.txt}
# since 3.0.0
export TS3SERVER_VOICE_DEFAULT_CREATE=${TS3SERVER_VOICE_DEFAULT_CREATE:-1}
# since 3.0.0
export TS3SERVER_VOICE_DEFAULT_PORT=${TS3SERVER_VOICE_DEFAULT_PORT:-9987}
# since 3.0.0
export TS3SERVER_VOICE_IP=${TS3SERVER_VOICE_IP:-0.0.0.0}

# environment processing
export _TS3SERVER_LICENSE_ACCEPTED=0
export TS3SERVER_VERSION=${TS3SERVER_VERSION:-0}
export TS3SERVER_SUPPORT_BADGE=$(vercompare ${TS3SERVER_VERSION} '>=' '3.0.9')
TS3SERVER_DB_SQL_CREATE_PATH=$(trailingslash "${TS3SERVER_DB_SQL_CREATE_PATH}")
TS3SERVER_DB_SQL_PATH=$(trailingslash "${TS3SERVER_DB_SQL_PATH}")
TS3SERVER_LOG_PATH=$(trailingslash "${TS3SERVER_LOG_PATH}")
TS3SERVER_QUERY_DOCS_PATH=$(trailingslash "${TS3SERVER_QUERY_DOCS_PATH}")
if [[ ${TS3SERVER_SUPPORT_BADGE} != true ]]; then
	TS3SERVER_PATCH_BADGES_DISABLE=false
fi
if [[ ${TS3SERVER_LICENSE} == "accept" ]]; then
	touch .ts3server_license_accepted
	_TS3SERVER_LICENSE_ACCEPTED=1
fi
if [[ ! ${TS3SERVER_QUERY_BUFFER} -ge 1 ]]; then
	TS3SERVER_QUERY_BUFFER=20
fi

# environment printing
if [[ "${TS3SERVER_PRINT_ENV}" == "true" ]]; then
  echo ---
  printenv | grep '^TS3SERVER_' | grep -v 'PASSWORD' | sort
  echo ---
fi

# patches
if [[ "${TS3SERVER_PATCH_ENABLE}" == "true" ]]; then
	# Patch for disable badges
	if [[ "${TS3SERVER_PATCH_BADGES_DISABLE}" == "true" ]]; then
		sed -e 's/client_badges/client_BADGES/g' -i ts3server
	fi
	# Patch for disable GDPR save database
	if [[ "${TS3SERVER_PATCH_GDPR_SAVE}" == "true" ]]; then
		cp -a patches/client_update_stats.sql sql/client_update_stats.sql
	fi
fi

cat <<- EOF >/app/ts3server.ini
default_voice_port=${TS3SERVER_VOICE_DEFAULT_PORT}
voice_ip=${TS3SERVER_VOICE_IP}
create_default_virtualserver=${TS3SERVER_VOICE_DEFAULT_CREATE}
machine_id=${TS3SERVER_MACHINE_ID}
filetransfer_port=${TS3SERVER_FILETRANSFER_PORT}
filetransfer_ip=${TS3SERVER_FILETRANSFER_IP}
query_port=${TS3SERVER_QUERY_PORT}
query_ip=${TS3SERVER_QUERY_IP}
clear_database=${TS3SERVER_DB_CLEAR}
logpath=${TS3SERVER_LOG_PATH}
dbplugin=${TS3SERVER_DB_PLUGIN}
dbpluginparameter=${TS3SERVER_DB_PLUGINPARAMETER}
dbsqlpath=${TS3SERVER_DB_SQL_PATH}
dbsqlcreatepath=${TS3SERVER_DB_SQL_CREATE_PATH}
licensepath=${TS3SERVER_LICENSE_PATH}
query_ip_whitelist=${TS3SERVER_QUERY_WHITELIST}
query_ip_backlist=${TS3SERVER_QUERY_BLACKLIST}
dbclientkeepdays=${TS3SERVER_DB_CLIENT_DAYS}
dblogkeepdays=${TS3SERVER_DB_LOG_DAYS}
logquerycommands=${TS3SERVER_LOG_QUERY_COMMANDS}
no_permission_update=${TS3SERVER_DB_UPDATE_DISABLE}
dbconnections=${TS3SERVER_DB_CONNECTIONS}
logappend=${TS3SERVER_LOG_APPEND}
disable_db_logging=${TS3SERVER_DB_LOGGING_DISBALE}
query_skipbruteforcecheck=${TS3SERVER_QUERY_BRUTFORCECHECK_DISABLE}
serverquerydocs_path=${TS3SERVER_QUERY_DOCS_PATH}
license_accepted=${_TS3SERVER_LICENSE_ACCEPTED}
http_proxy=${TS3SERVER_PROXY}
query_buffer_mb=${TS3SERVER_QUERY_BUFFER}
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
set -- "$@" inifile=/app/ts3server.ini
if [ -n "${TS3SERVER_QUERY_PASSWORD}" ]; then
    set -- "$@" serveradmin_password=${TS3SERVER_QUERY_PASSWORD}
fi

# execution
exec ./ts3server "$@"
