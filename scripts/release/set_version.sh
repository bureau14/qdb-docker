#!/bin/bash

if [[ $# -ne 1 ]] ; then
    >&2 echo "Usage: $0 <new_version>"
    exit 1
fi

INPUT_VERSION=$1; shift

IFS='.-' read -ra VERSION_PARTS <<< "${INPUT_VERSION}"

XYZ_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}"

cd $(dirname -- $0)
cd ${PWD}/../..

if [[ "${INPUT_VERSION}" == *-* ]] ; then
    # nightly
    # QDB_NIGHTLY_VERSION=2.2.0
    sed -i -e 's/\(QDB_NIGHTLY_VERSION\)=.*/\1='${XYZ_VERSION}'/' versions.sh
else
    # stable release
    # QDB_LATEST_VERSION=2.2.0
    sed -i -e 's/\(QDB_LATEST_VERSION\)=.*/\1='${XYZ_VERSION}'/' versions.sh
fi
