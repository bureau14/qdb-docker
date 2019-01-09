#!/bin/bash

set -ex
set -o pipefail

AWSCLI=`which aws`
S3_BUCKET="qdbbuilddeps"
S3_PATH="s3://${S3_BUCKET}/datasets"
DS_PATH="qdb-preloaded/datasets"

function warn {
    echo $1
}

BASEDIR=$(pwd)

for DIR in ${DS_PATH}/*/
do
    if [[ ${DIR} =~ (${DS_PATH}/(.+)/$) ]]
    then
        IDENTIFIER=${BASH_REMATCH[2]}
        ${AWSCLI} s3 cp ${S3_PATH}/${IDENTIFIER}.csv ${DS_PATH}/${IDENTIFIER}/data.csv || warn "Dataset does not exist on S3: ${IDENTIFIER}"
        echo "current path: $(pwd)"
        # cd ${DS_PATH}/${IDENTIFIER}/ && ./download.sh || warn "No downloader exists: ${IDENTIFIER}"
        cd ${BASEDIR}
    fi

done


echo "Loaded all datasets"
