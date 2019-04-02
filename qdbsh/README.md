## QuasarDB Shell Dockertfile

This repository contains the **Dockerfile** of [QuasarDB](http://www.quasardb.net/) shell for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bureau14/qdbsh/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Supported tags

|version|tags|
|---|---|
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
1. Pull from docker: `docker pull bureau14/qdbsh`
1. Alternatively: build an image with a [Dockerfile](https://hub.docker.com/r/bureau14/qdbsh/~/dockerfile/)
1. Required files (replace {version} with the version you wish to use):
	1. qdb-api_{version}-1.deb
	1. qdb-utils_{version}-1.deb



### Usage

#### Run `qdbsh` with a `qdb` container

    mkdir /db1 && cp license.txt /db1/license.txt
    mkdir /db2 && cp license.txt /db2/license.txt
    mkdir /db3 && cp license.txt /db3/license.txt

    docker run -d --name qdb-server1 bureau14/qdb -v /db1:/var/lib/qdb --security=0 --log-level=debug
    docker run -d --name qdb-server2 --link qdb-server1:successor -v /db2:/var/lib/qdb bureau14/qdb --peer successor:2836 --security=0 --log-level=debug
    docker run -d --name qdb-server3 --link qdb-server2:successor bureau14/qdb -v /db3:/var/lib/qdb --peer successor:2836 --security=0 --log-level=debug
    docker run -ti --link qdb-server1:qdb-server bureau14/qdbsh --cluster qdb://qdb-server:2836


    docker logs  qdb-server1 | grep successor
    07:18:10.967661999    38        debug   ring stabilization for 172.17.0.2:2836 changed successor from 172.17.0.2:2836 to 172.17.0.3:2836
    07:18:10.967867477    38        info    cached 1 new successor(s)
    07:18:23.650560746    38        debug   ring stabilization for 172.17.0.2:2836 changed successor from 172.17.0.3:2836 to 172.17.0.4:2836
    07:18:23.650939296    38        info    cached 1 new successor(s)
