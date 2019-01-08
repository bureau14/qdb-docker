#!/bin/bash

TARBALL_QDB=
TARBALL_QDB_WEB_BRIDGE=
TARBALL_QDB_PHP=
EGG_QDB_PYTHON=
DEBIAN_PACKAGE_QDB=
DEBIAN_PACKAGE_QDB_UTILS=
DEBIAN_PACKAGE_QDB_API=
DEBIAN_PACKAGE_QDB_REST=
DEBIAN_PACKAGE_QDB_DASHBOARD=

function set_files {
    TARBALL_QDB="qdb-${QDB_VERSION}-linux-64bit-server.tar.gz"
    TARBALL_QDB_API="qdb-${QDB_VERSION}-linux-64bit-c-api.tar.gz"
    TARBALL_QDB_REST="qdb-${QDB_VERSION}-linux-64bit-rest.tar.gz"
    TARBALL_QDB_UTILS="qdb-${QDB_VERSION}-linux-64bit-utils.tar.gz"
    TARBALL_QDB_WEB_BRIDGE="qdb-${QDB_VERSION}-linux-64bit-web-bridge.tar.gz"
    TARBALL_QDB_PHP="quasardb-${QDB_VERSION}.tgz"
    EGG_QDB_PYTHON="quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg"
    DEBIAN_PACKAGE_QDB_DASHBOARD="qdb-dashboard_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
}
