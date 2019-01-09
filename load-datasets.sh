#!/bin/bash

set -ex
set -o pipefail

AWSCLI=`which aws`
S3_BUCKET="qdbbuilddeps"
S3_PATH="s3://${S3_BUCKET}/datasets"
PATH="qdb-preloaded/datasets"

function warn {
    echo $1
}

for DIR in ${PATH}/*/
do
    if [[ ${DIR} =~ (${PATH}/(.+)/$) ]]
    then
        IDENTIFIER=${BASH_REMATCH[2]}
        ${AWSCLI} s3 cp ${S3_PATH}/${IDENTIFIER}.csv ${PATH}/${IDENTIFIER}/data.csv || warn "Dataset does not exist on S3: ${IDENTIFIER}"
    fi
done


echo "Loaded all datasets"
