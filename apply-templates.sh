#!/usr/bin/env bash
set -eu -o pipefail

BASEDIR=$(dirname "$(readlink -f "${BASH_SOURCE}")")

CONFIG_FILE="${BASEDIR}/versions.json"
TEMPLATE_DIR="${BASEDIR}/templates/"
JQT="scripts/jq-template.awk"

[ -f "${CONFIG_FILE}" ] && [ -d "${TEMPLATE_DIR}" ]

IFS=$'\n'
COMPONENTS=$(find templates/ -mindepth 1 -maxdepth 1 -type d | awk -F/ '{ print $2 }')
COMPONENTS=($COMPONENTS)

VERSIONS="$(jq -r 'keys | map(@sh) | join(" ")' ${CONFIG_FILE})"

generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

eval "set -- $VERSIONS"
for major
do
    export major
    rm -rf "$major"

    version="$(jq -r '.[env.major].version' ${CONFIG_FILE})"
    export version

    INDIR="templates"
    OUTDIR="$major"
    mkdir -p "$OUTDIR"

    {
        generated_warning
	gawk -f "${JQT}" "${INDIR}/Dockerfile.template"
    } > "${OUTDIR}/Dockerfile"

    {
        generated_warning
	gawk -f "${JQT}" "${INDIR}/Makefile.template"
    } > "${OUTDIR}/Makefile"

    unset INDIR
    unset OUTDIR

    qdb_server_url=$(jq -r '.[env.major].files."qdb-server"' versions.json)
    qdb_utils_url=$(jq -r '.[env.major].files."qdb-utils"' versions.json)
    qdb_api_c_url=$(jq -r '.[env.major].files."qdb-api-c"' versions.json)
    qdb_api_rest_url=$(jq -r '.[env.major].files."qdb-api-rest"' versions.json)
    qdb_kinesis_connector_url=$(jq -r '.[env.major].files."qdb-kinesis-connector"' versions.json)

    export qdb_server_url
    export qdb_utils_url
    export qdb_api_c_url
    export qdb_api_rest_url
    export qdb_kinesis_connector_url

    for component in "${COMPONENTS[@]}"
    do
        export component

        INDIR="templates/$component"
        [ -d "${INDIR}" ]

	OUTDIR="$major/$component"
	mkdir -p "$OUTDIR"

	echo "processing $OUTDIR ..."

        {
            generated_warning
	    gawk -f "${JQT}" "${INDIR}/Dockerfile.template"
        } > "${OUTDIR}/Dockerfile"

        find ${INDIR} -type f ! -name Dockerfile.template -exec cp {} ${OUTDIR}/ \;
    done
done
