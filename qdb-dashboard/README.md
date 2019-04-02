## QuasarDB Dashboard Dockerfile

This repository contains the **Dockerfile** of [QuasarDB](http://www.quasardb.net/) shell for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bureau14/qdb-dashboard/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Supported tags

|version|tags|
|---|---|
|`3.0.0`|	3.0.0,	3.0|
|`3.1.0`|	3.1.0,	3.1|
|`3.2.0`|	3.2.0,	3.2,	latest|
|`3.3.0`|	3.3.0,	3.3,	nightly|


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)

### Installation

1. Install [Docker](https://www.docker.com/).
1. Pull from docker: `docker pull bureau14/qdb-dashboard`
1. Alternatively: build an image with a [Dockerfile](https://hub.docker.com/r/bureau14/qdb-dashboard/~/dockerfile/)
1. Required files (replace {version} with the version you wish to use):
	1. qdb-{version}-linux-64bit-c-api.tar.gz
	1. qdb-{version}-linux-64bit-rest.tar.gz

