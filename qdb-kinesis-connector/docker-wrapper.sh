#!/usr/bin/env bash

set -eu

is_java_cmd() {
  [ "$(which java)" = "$1" -o "$(readlink -f $(which java))" = "$1" ]
}

is_true() {
  if [[ ${1,,} = "true" ]]; then
    true
  else
    false
  fi
}

echo "Got input parameters $@"

# Normalize invocations of "java" so that other scripts can more easily detect it
if is_java_cmd "$1"; then
  shift
  set -- java "$@"
# else if the first argument is not executable assume java
elif ! type "$1" &>/dev/null; then
  set -- java "$@"
fi

get_available_memory () {
    local default_memory=

    local cgroup_version=$(findmnt -o FSTYPE -n /sys/fs/cgroup)

    if [ "${cgroup_version}" = "cgroup2" ]
    then
        if [ -f "/sys/fs/cgroup/memory.max" ]
        then
            default_memory=$(awk '{ print int($1/1024/1024) }' /sys/fs/cgroup/memory.max)
        fi
    elif [ "${cgroup_version}" = "cgroup" ]
    then
        if [ -f "/sys/fs/cgroup/memory/memory.limit_in_bytes" ]
        then
            default_memory=$(awk '{ print int($1/1024/1024) }' /sys/fs/cgroup/memory/memory.limit_in_bytes)
        fi
    fi

    if [ ! -n "${default_memory}" ] || [ "${default_memory}" = "0" ]
    then
        # Likely no cgroup, or no cgroup memory limit, attempt to use system total memory
        default_memory=$(cat /proc/meminfo | grep '^MemTotal' | awk '{print int($2/1024)}')
    fi

    local memory=""
    if [ -n "$JVM_MEMORY_LIMIT" ]; then
        memory=$((JVM_MEMORY_LIMIT / (1024 * 1024)))
    fi

    # Fallback to default memory limit
    if [ -z $memory ]; then
        memory=$default_memory
    fi

    echo $memory
}

export JVM_MEMORY_MB=${JVM_MEMORY_MB:-$(get_available_memory)}
export JVM_HEAP_SIZE_RATIO=${JVM_HEAP_SIZE_RATIO:-"25"}
export JVM_HEAP_SIZE_MB=${JVM_HEAP_SIZE_MB:-$(expr ${JVM_MEMORY_MB} \* ${JVM_HEAP_SIZE_RATIO} / 100)}

export JAVA_HEAP_OPTS=${JAVA_HEAP_OPTS:-"-Xms${JVM_HEAP_SIZE_MB}M -Xmx${JVM_HEAP_SIZE_MB}M"}

export JMX_PORT=${JMX_PORT:-"43210"}
export JMX_OPTS=
if is_true "$JMX_ENABLE"
then
    echo "Enabling JMX management via port ${JMX_PORT}"
    JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.port=${JMX_PORT} -Dcom.sun.management.jmxremote.rmi.port=${JMX_PORT} -Djava.rmi.server.hostname=127.0.0.1"
fi

export JAVA_GC_OPTS=${JAVA_GC_OPTS:-"-XX:+UseZGC -XX:+PrintCommandLineFlags"}


if [[ ! -z ${JVM_GC_MAX_PARALLEL_THREADS} ]]
then
    echo "Setting max parallel GC threads: ${JVM_GC_MAX_PARALLEL_THREADS}"
    JAVA_GC_OPTS=${JAVA_GC_OPTS:-" -XX:ParallelGCThreads=${JVM_GC_PARALLEL_THREADS}"}
fi

if [[ ! -z ${JVM_GC_MAX_PAUSE_MS} ]]
then
    echo "Setting max GC pause to ${JVM_GC_MAX_PAUSE_MS} milliseconds."
    JAVA_GC_OPTS=${JAVA_GC_OPTS:-" -XX:MaxGCPauseMillis=${JVM_GC_MAX_PAUSE_MS}"}
fi

export JAVA_LOG4J2_OPTS=
if [[ ! -z ${LOG4J2_XML} ]]
then
    if [[ ! -z ${LOG_PATH} ]]
    then
        echo "Patching log4j2 configuration with log path: ${LOG_PATH}"

        # Create a copy of the config, since the config may come from outside and be a
        # mounted volume, and we want to avoid `sed`'ing those files.
        #
        # Note: using | as sed control character here, to avoid issues with `/` in path name.
        LOG4J2_XML_TMP=$(mktemp)
        sed 's|{{QDB_KINESIS_LOG_PATH}}|'"${LOG_PATH}"'|g' ${LOG4J2_XML} > ${LOG4J2_XML_TMP}
        echo "Created new log config ${LOG4J2_XML_TMP}"
        LOG4J2_XML="${LOG4J2_XML_TMP}"
    fi

    echo "log4j2.xml contents: "
    echo "--------------------------"
    cat ${LOG4J2_XML_TMP}
    echo "--------------------------"

    echo "Setting log4j2 configuration XML to: ${LOG4J2_XML}"
    JAVA_LOG4J2_OPTS+=${JAVA_LOG4J2_OPTS:-"-Dlog4j2.configurationFile=${LOG4J2_XML} "}
fi

# Now handle kinesis-custom java options
JAVA_KINESIS_OPTS=
if [[ ! -z ${CLUSTER_URI} ]]
then
    echo "Enabling QuasarDB cluster uri ${CLUSTER_URI}"
    JAVA_KINESIS_OPTS+="--cluster ${CLUSTER_URI} "
fi

if [[ ! -z ${CLUSTER_PUBLIC_KEY_FILE} ]]
then
    echo "Setting public key file: ${CLUSTER_PUBLIC_KEY_FILE}"
    JAVA_KINESIS_OPTS+="--cluster-public-key ${CLUSTER_PUBLIC_KEY_FILE} "
fi

if [[ ! -z ${USER_SECURITY_FILE} ]]
then
    echo "Setting public key file: ${USER_SECURITY_FILE}"
    JAVA_KINESIS_OPTS+="--user-security-file ${USER_SECURITY_FILE} "
fi

if [[ ! -z ${ROLE_ARN} ]]
then
    echo "Setting role ARN: ${ROLE_ARN}"
    JAVA_KINESIS_OPTS+="--role-arn ${ROLE_ARN} "
fi

if [[ ! -z ${EXTERNAL_ID} ]]
then
    echo "Setting external id"
    JAVA_KINESIS_OPTS+="--external-id ${EXTERNAL_ID} "
fi

if [[ ! -z ${RELAY_RESET_INTERVAL_MS} ]]
then
    echo "Setting relay reset interval to ${RELAY_RESET_INTERVAL_MS} ms"
    JAVA_KINESIS_OPTS+="--relay-reset-interval ${RELAY_RESET_INTERVAL_MS} "
fi

if [[ ! -z ${RELAY_QUEUE_SIZE} ]]
then
    echo "Setting relay queue size: ${RELAY_QUEUE_SIZE}"
    JAVA_KINESIS_OPTS+="--relay-queue-size ${RELAY_QUEUE_SIZE} "
fi

if [[ ! -z ${RELAY_POOL_SIZE} ]]
then
    echo "Setting relay pool size: ${RELAY_POOL_SIZE}"
    JAVA_KINESIS_OPTS+="--relay-pool-size ${RELAY_POOL_SIZE} "
fi

if [[ ! -z ${THREADS} ]]
then
    echo "Setting thread count: ${THREADS}"
    JAVA_KINESIS_OPTS+="--threads ${THREADS} "
fi

if [[ ! -z ${PUSH_MODE} ]]
then
    echo "Setting push-mode: ${PUSH_MODE}"
    JAVA_KINESIS_OPTS+="--push-mode ${PUSH_MODE} "
fi

if [[ ! -z ${BLACKLIST_FILE} ]]
then
    if [[ ! -e "${BLACKLIST_FILE}" ]]
    then
        touch ${BLACKLIST_FILE}
    fi

    echo "Setting blacklist file: ${BLACKLIST_FILE}"
    JAVA_KINESIS_OPTS+="--blacklist-file ${BLACKLIST_FILE} "
fi

if [[ ! -z ${STREAM_NAME} ]]
then
    echo "Setting Kinesis stream name: ${STREAM_NAME}"
    JAVA_KINESIS_OPTS+="--stream-name ${STREAM_NAME} "
fi

if [[ ! -z ${PARSER} ]]
then
    echo "Setting parser: ${PARSER}"
    JAVA_KINESIS_OPTS+="--parser ${PARSER} "
fi

if [[ ! -z ${STOP_AFTER_MS} ]]
then
    echo "Setting stop-after: ${STOP_AFTER_MS}ms"
    JAVA_KINESIS_OPTS+="--stop-after ${STOP_AFTER_MS} "
fi

if [[ ! -z ${RECORD_REJECTION_AGE_MS} ]]
then
    echo "Setting record-rejection-age: ${RECORD_REJECTION_AGE_MS}ms"
    JAVA_KINESIS_OPTS+="--record-rejection-age ${RECORD_REJECTION_AGE_MS} "
fi

# Push the kinesis options into the stack
set -- "$@" ${JAVA_KINESIS_OPTS}

export JAVA_OPTS=${JAVA_OPTS:--showversion -server ${JAVA_LOG4J2_OPTS} ${JAVA_HEAP_OPTS} ${JAVA_GC_OPTS} ${JMX_OPTS}}


# Do we have JAVA_OPTS for a java command?
if [ "$1" = "java" -a -n "$JAVA_OPTS" ]
then
    shift
    set -- java $JAVA_OPTS "$@"
fi

echo "Starting command: $*"
exec "$@"
