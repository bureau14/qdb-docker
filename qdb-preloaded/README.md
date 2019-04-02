## QuasarDB preloaded Dockerfile

This repository contains the **Dockerfile** of [QuasarDB](http://www.quasardb.net/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bureau14/qdb/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Supported tags

|version|tags|
|---|---|
|`3.1.0`|	3.1.0|
|`3.2.0`|	3.2.0,	latest|


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)

### Installation

1. Install [Docker](https://www.docker.com/).
1. Pull from docker: `docker pull bureau14/qdb-preloaded`
1. Alternatively: build an image with a [Dockerfile](https://hub.docker.com/r/bureau14/qdb-preloaded/~/dockerfile/)
1. Required files (replace {version} with the version you wish to use):
	1. qdb-api_{version}-1.deb
	1. qdb-utils_{version}-1.deb

