## QuasarDB Replication utility Dockerfile

This repository contains the **Dockerfile** of [QuasarDB](http://www.quasardb.net/) replication utility for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/bureau14/qdbsh/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Supported tags

|version|tags|
|---|---|
|`2.6.0`|	2.6.0,	2.6|
|`2.7.0`|	2.7.0,	2.7|
|`2.8.0`|	2.8.0,	2.8|
|`3.0.0`|	3.0.0,	3.0|
|`3.1.0`|	3.1.0,	3.1|
|`3.2.0`|	3.2.0,	3.2|
|`3.3.0`|	3.3.0,	3.3|
|`3.4.2`|	3.4.2,	3.4,	latest|
|`3.5.0`|	3.5.0,	3.5,	nightly|


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)

### Installation

1. Install [Docker](https://www.docker.com/).
1. Pull from docker: `docker pull bureau14/qdbsh`
1. Alternatively: build an image with a [Dockerfile](https://hub.docker.com/r/bureau14/qdb-replicate/~/dockerfile/)
1. Required files (replace {version} with the version you wish to use):
	1. qdb-utils_{version}-1.deb

### Usage

#### Run `qdb-replicate` with two `qdb` containers

The example below launch two (standalone) qdb containers, i.e. effectively two seraparate clusters. We will then insert some data in the primary cluster (cluster1) and replicate changes to the secondary cluster (cluster2):

     docker run -d --name cluster1 bureau14/qdb 
     docker run -d --name cluster2 bureau14/qdb

Insert some data into the primary cluster:

```
$ docker run -ti --link cluster1:cluster1 bureau14/qdbsh --cluster qdb://cluster1:2836
quasardb shell version 3.4.1 build 3c73041 2019-08-08 14:56:08 +0000
Copyright (c) 2009-2019 quasardb. All rights reserved.

Need some help? Check out our documentation here:  https://doc.quasardb.net

qdbsh > CREATE TABLE orders (volume INT64, price DOUBLE)

qdbsh > INSERT INTO orders ($timestamp, volume, price) VALUES (now(), 1000, 50.0)

qdbsh > SELECT * FROM orders
$timestamp                       timeseries   volume            price
----------------------------------------------------------------------
2019-10-02T09:03:09.410700517Z       orders    1,000               50

Returned 1 row in 1,301 us
Scanned 2 rows in 1,301 us (1,537 rows/sec)

qdbsh > 
```

And replicate the data between the clusters:

```
$ docker run -ti --link cluster1:cluster1 --link cluster2:cluster2 bureau14/qdb-replicate --source qdb://cluster1:2836/ --destination qdb://cluster2:2836/
Finished cluster copy from scratch (matching at least transaction c5fe30bf0154acc-5d63bd06e7878b9c-5f635b3cf7fc3560-dbe35df7b5080651:2019.10.02-09.11.16.769982479 UTC).
Replication completed in 0.009 seconds.
```

And we can now verify we have the data in the secondary cluster as well:

```
$ docker run -ti --link cluster2:cluster2 bureau14/qdbsh --cluster qdb://cluster2:2836
quasardb shell version 3.4.1 build 3c73041 2019-08-08 14:56:08 +0000
Copyright (c) 2009-2019 quasardb. All rights reserved.

Need some help? Check out our documentation here:  https://doc.quasardb.net

qdbsh > SELECT * FROM orders
$timestamp                       timeseries   volume            price
----------------------------------------------------------------------
2019-10-02T09:03:09.410700517Z       orders    1,000               50

Returned 1 row in 1,301 us
Scanned 2 rows in 1,301 us (1,537 rows/sec)

qdbsh > 
```

You now managed to replicate cluster state from the primary cluster (cluster1) to the secondary (cluster2). Whenever you want to update the state, relaunch the qdb-replicate container and it will synchronize them. This can be as frequent as you want: every minute will not be a problem.