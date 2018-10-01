#!/usr/bin/env sh

QDB_SERVER=`which qdbd`
QDB_LAUNCH_ARGS=""

echo "Launching qdbd bound to eth0:2836"
QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} -a eth0:2836"

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
