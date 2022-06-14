#!/usr/bin/env bash
set -eu -o pipefail

BASEDIR=$(dirname "$(readlink -f "${BASH_SOURCE}")")
CONFIG_FILE="${BASEDIR}/config.json"
SUBDIRS_="$(jq -r '.versions | keys | map(@sh) | join(" ")' ${CONFIG_FILE})"
eval "SUBDIRS=( $SUBDIRS_ )"

BEFORE=$(find ${SUBDIRS} -type f -exec sha256sum {} \; | sort | sha256sum)

/usr/bin/env bash -c "${BASEDIR}/apply-templates.sh"

AFTER=$(find ${SUBDIRS} -type f -exec sha256sum {} \; | sort | sha256sum)

if [[ "${BEFORE}" != "${AFTER}" ]]
then
    echo "templates dirty: '${BEFORE}' != '${AFTER}'"
    exit -1
fi

exit 0
