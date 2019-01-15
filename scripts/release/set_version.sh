#!/bin/bash

if [[ $# -ne 1 ]] ; then
    >&2 echo "Usage: $0 <new_version>"
    exit 1
fi

INPUT_VERSION=$1; shift

MAJOR_VERSION=${INPUT_VERSION%%.*}
WITHOUT_MAJOR_VERSION=${INPUT_VERSION#${MAJOR_VERSION}.}
MINOR_VERSION=${WITHOUT_MAJOR_VERSION%%.*}
WITHOUT_MINOR_VERSION=${INPUT_VERSION#${MAJOR_VERSION}.${MINOR_VERSION}.}
PATCH_VERSION=${WITHOUT_MINOR_VERSION%%.*}

XYZ_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}"

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
