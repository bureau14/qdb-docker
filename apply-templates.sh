#!/usr/bin/env bash
set -eu -o pipefail

BASEDIR=$(dirname "$(readlink -f "${BASH_SOURCE}")")

CONFIG_FILE="${BASEDIR}/config.json"
TEMPLATE_DIR="${BASEDIR}/templates/"
JQT="scripts/jq-template.awk"

[ -f "${CONFIG_FILE}" ] && [ -d "${TEMPLATE_DIR}" ]

IFS=$'\n'

COMPONENTS="$(jq -r '.components | keys | map(@sh) | join(" ")' ${CONFIG_FILE})"
VERSIONS="$(jq -r '.versions | keys | map(@sh) | join(" ")' ${CONFIG_FILE})"

generated_warning() {
    local file_type="$1"
    cat <<-EOH
		#
		# NOTE: THIS ${file_type^^} IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#
	EOH
}

###
# Utility that gets a file's url. Uses environment's version/variant to peek
# into the correct key/value.
#
# Yields empty result if key not found.
get_file_url() {
    local key="${1}"
    local value="$(jq -r '.versions | .[env.version] | .[env.variant] | ."'${key}'"' ${CONFIG_FILE})"

    if [[ "${value}" == "null" ]]
    then
        value=""
    fi

    echo "${value}"
}

eval "set -- $VERSIONS"
for version
do
    rm -rf "${version}"
done

eval "set -- $VERSIONS"
for version
do

    export version
    echo "+   ${version}"
    mkdir -p "${version}"

    {
        generated_warning Makefile
	gawk -f "${JQT}" "templates/Makefile.template"
    } > "${version}/Makefile"


    VARIANTS="$(jq -r '.variants | map(@sh) | join(" ")' ${CONFIG_FILE})"
    eval "set -- $VARIANTS"
    for variant
    do
        export variant

        subdir="${version}/${variant}"
        echo "++  $subdir"

        export subdir

        INDIR="templates/variant"
        OUTDIR="${subdir}"
        mkdir -p "$OUTDIR"

        {
            generated_warning Dockerfile
	    gawk -f "${JQT}" "${INDIR}/Dockerfile.template"
        } > "${OUTDIR}/Dockerfile"

        {
            generated_warning Makefile
	    gawk -f "${JQT}" "${INDIR}/Makefile.template"
        } > "${OUTDIR}/Makefile"

        # cp ${INDIR}/retry.sh ${OUTDIR}/retry.sh

        qdb_server_url=$(get_file_url "qdb-server")
        qdb_utils_url=$(get_file_url "qdb-utils")
        qdb_api_c_url=$(get_file_url "qdb-api-c")
        qdb_api_rest_url=$(get_file_url "qdb-api-rest")
        qdb_kinesis_connector_url=$(get_file_url "qdb-kinesis-connector")

        export qdb_server_url
        export qdb_utils_url
        export qdb_api_c_url
        export qdb_api_rest_url
        export qdb_kinesis_connector_url

        eval "set -- $COMPONENTS"

        for component
        do
            ###
            # TODO(leon): A bit of a hack to put this in here, because this effectively
            #             describes the dependencies of qdb-dashboard on the REST API url.
            #
            #             A better approach would be to somehow declare/detect which URLs
            #             a component needs, and skip it if the required URLs are not
            #             available.
            #
            if ([[ "${component}" == "qdb-dashboard" ]] && [[ "${qdb_api_rest_url}" == "" ]]) || ([[ "${component}" == "qdb-kinesis-connector" ]] && [[ "${qdb_kinesis_connector_url}" == "" ]])
            then
                continue
            fi

            echo "+++ ${subdir}/${component}"

            export component

            INDIR="templates/variant/component/$component"
            [ -d "${INDIR}" ]

	    OUTDIR="$subdir/$component"
	    mkdir -p "$OUTDIR"

            {
                generated_warning Makefile
	        gawk -f "${JQT}" "templates/variant/component/Makefile.template"
            } > "${OUTDIR}/Makefile"

            {
                generated_warning Dockerfile
	        gawk -f "${JQT}" "${INDIR}/Dockerfile.template"
            } > "${OUTDIR}/Dockerfile"

            find ${INDIR} -type f ! -name *.template  -exec cp {} ${OUTDIR}/ \;

            unset component
        done
    done

    unset qdb_server_url
    unset qdb_utils_url
    unset qdb_api_c_url
    unset qdb_api_rest_url
    unset qdb_kinesis_connector_url
done
