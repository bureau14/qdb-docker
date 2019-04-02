## QuasarDB Dockerfile

This repository contains the **Dockerfile** of [QuasarDB](http://www.quasardb.net/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bureau14/qdb/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Supported tags

|version|tags|
|---|---|
|`2.1.0`|	2.1.0,	2.1|
|`2.3.0`|	2.3.0,	2.3|
|`2.4.0`|	2.4.0,	2.4|
|`2.5.0`|	2.5.0,	2.5|
|`2.6.0`|	2.6.0,	2.6|
|`2.7.0`|	2.7.0,	2.7|
|`2.8.0`|	2.8.0,	2.8|
|`3.0.0`|	3.0.0,	3.0|
|`3.1.0`|	3.1.0,	3.1|
|`3.2.0`|	3.2.0,	3.2,	latest|
|`3.3.0`|	3.3.0,	3.3,	nightly|


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)

### Installation

1. Install [Docker](https://www.docker.com/).
1. Pull from docker: `docker pull bureau14/qdb`
1. Alternatively: build an image with a [Dockerfile](https://hub.docker.com/r/bureau14/qdb/~/dockerfile/)
1. Required files (replace {version} with the version you wish to use):
	1. qdb-{version}-linux-64bit-server.tar.gz



### Usage

#### Run `qdbd`

    docker run -d -p 2836:2836 --name qdb-server bureau14/qdb

#### Run `qdbd` without security

    docker run -d -p 2836:2836 --name qdb-server -e QDB_DISABLE_SECURITY=true bureau14/qdb

#### Run `qdbd` and connect with `qdbsh`

    docker run -d -p 2836:2836 --name qdb-server -e QDB_DISABLE_SECURITY=true bureau14/qdb
    docker run -ti --link qdb-server:qdb-server bureau14/qdbsh --cluster qdb://qdb-server:2836

#### Run `qdbd` and connect with the dashboard

    docker run -d -p 2836:2836 --name qdb-server -e QDB_DISABLE_SECURITY=true bureau14/qdb
    docker run -ti -p 40000:40000 --link qdb-server:qdb-server -e QDB_URI=qdb://qdb-server:2836/ bureau14/qdb-dashboard

    You can now navigate to http://localhost:40000/#anonymous to log in into the dashboard.

#### Run `qdbd` w/ persistent directory

    docker run -d -p 2836:2836 -v <db-dir>:/var/lib/qdb --name qdb-server bureau14/qdb

#### Run `qdbd` w/ license file and persistent directory

    # Put the license.txt file in the root of your <db-dir>
    cp license.txt <db-dir>

    # Now launch the docker container with the <db-dir> mounted, the container will
    # pick up the license file automatically.
    docker run -d -p 2836:2836 -v <db-dir>:/var/lib/qdb --name qdb-server bureau14/qdb
