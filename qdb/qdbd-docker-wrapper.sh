#!/usr/bin/env sh

set -e
set -x

QDB_SERVER=`which qdbd`
QDB_LAUNCH_ARGS=""
IP=`which ip`
AWK=`which awk`

IP=`${IP} route get 8.8.8.8 | grep -oh 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $2}'`

echo "Launching qdbd bound to ${IP}:2836"
QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} -a ${IP}:2836"

# Detects the presence of a license file, and provides it as an
# argument to `qdbd` if found.
POTENTIAL_LICENSE_FILE="/var/lib/qdb/license.txt"

if [ -f ${POTENTIAL_LICENSE_FILE} ]; then
    echo "license file found! ${POTENTIAL_LICENSE_FILE}"
    QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} --license-file ${POTENTIAL_LICENSE_FILE}"
fi

if [ "${QDB_DISABLE_SECURITY}" = "true" ]
then
    QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} --security=0"
fi

echo "Launching qdb with arguments: ${QDB_LAUNCH_ARGS}"

${QDB_SERVER} ${QDB_LAUNCH_ARGS} $@
