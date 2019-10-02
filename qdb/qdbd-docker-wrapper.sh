#!/usr/bin/env sh

set -e
set -x

QDB_CONFIG=${QDB_CONFIG_PATH:-"/opt/qdb/etc/qdbd.conf"}
QDB_SERVER="/opt/qdb/bin/qdbd"
QDB_LAUNCH_ARGS=""
IP=`which ip`
AWK=`which awk`

IP=`${IP} route get 8.8.8.8 | grep -oh 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $2}'`

echo "Launching qdbd bound to ${IP}:2836"
QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} -a ${IP}:2836"

if [ "${QDB_DISABLE_SECURITY}" = "true" ]
then
    QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} --security=0"
fi

if [ "${QDB_CONFIG_PATH}" != "" ]
then
    QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} --config=${QDB_CONFIG_PATH}"
fi

echo "Launching qdb with arguments: ${QDB_LAUNCH_ARGS}"

${QDB_SERVER} --config ${QDB_CONFIG} ${QDB_LAUNCH_ARGS} $@
