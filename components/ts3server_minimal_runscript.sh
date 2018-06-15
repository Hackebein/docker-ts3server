#!/bin/sh

export LD_LIBRARY_PATH=".:./redist:$LD_LIBRARY_PATH"

D1=$(readlink -f "$0")
D2=$(dirname "${D1}")
cd "${D2}"

# vercomp '3.0.0' $TS3SERVER_VERSION
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
	
	if [[ $op != $2 ]]; then
		return 1
	else
		return 0
	fi
}

# main
vercompare $TS3SERVER_VERSION '<' '3.0.9'
version_before_badge=$?
if $(exit $version_before_badge); then
	TS3SERVER_PATCH_BADGES_DISABLE='false'
fi

# DEBUG
env

if [ -e ts3server.dist ]; then
	cp -a ts3server.dist ts3server
	rm ts3server.dist
fi
if [ "${TS3SERVER_PATCH_ENABLE}" = "true" ]; then
	cp -a ts3server ts3server.dist
	# Patch for disable badges
	if [ "${TS3SERVER_PATCH_BADGES_DISABLE}" = "true" ]; then
		sed -e 's/client_badges/client_BADGES/g' -i ts3server
	fi
fi

# TODO: cmd param
# dbplugin=ts3db_mariadb
# dbpluginparameter=ts3db_mariadb.ini
# dbsqlpath=sql/
# dbsqlcreatepath=create_mariadb/
# query_port=10101
# filetransfer_ip=0.0.0.0 # do also if port only is set!
# filetransfer_port=30301
# TODO: ts3db_mariadb.ini
# [config]
# host=database
# port=3306
# username=ts3server
# password=Start123
# database=ts3server01
# socket=

# execution
if [ -z "${TS3SERVER_QUERY_PASSWORD}" ]; then
	exec ./ts3server $@
else
	exec ./ts3server serveradmin_password=${TS3SERVER_QUERY_PASSWORD} $@
fi
