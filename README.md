This repo contains dockerfiles (CentOS and Fedora) for GlusterFS containers namely server, client and S3.


The support matrix of GlusterFS and container versions:


|                |GlusterFS  Version                    |Container Tag   | Container name                     |
|----------------|-------------------------------|-----------------------------|------------------|
|GlusterFS Server Container|`v4.0,  v3.13, v3.12, v3.10`            |`gluster4u0_centos7`,`gluster3u13_centos7`, `gluster3u12_centos7`, `gluster3u10_centos7` |            `gluster-centos`|
|GlusterFS Client Container       |`v3.13`            |`latest`            |`glusterfs-client`
|Gluster S3 Server Container         |`v4.0,  v3.13, v3.12, v3.10`|`latest`|`gluster-s3`


## Gluster Server Docker container:

Although Setting up a glusterfs environment is a pretty simple and straight forward procedure, Gluster community do maintain docker images of gluster both Fedora and CentOS as base image in the docker hub for the ease of users. The community maintains docker images of GlusterFS release in both Fedora and CentOS distributions. 

The following are the steps to run the GlusterFS docker images that we maintain:

To pull the docker image from the docker hub run the following command:

### Fedora:

~~~
$ docker pull gluster/gluster-fedora
~~~

### CentOS:

~~~
$ docker pull gluster/gluster-centos
~~~

This will pull the glusterfs docker image from the docker hub.
Alternatively, one could build the image from the Dockerfile directly. For this, clone the gluster-containers source repository and build the image using Dockerfiles in the repository. For getting the source, One can make use of git:

~~~
$ git clone git@github.com:gluster/gluster-containers.git
~~~

This repository consists of Dockerfiles for GlusterFS to build on both CentOS and Fedora distributions. Once you clone the repository, to build the image, run the following commands:

For Fedora,

~~~
$ docker build -t gluster-fedora docker/Fedora/Dockerfile
~~~
For CentOS,
~~~
$ docker build -t gluster-centos docker/CentOS/Dockerfile
~~~
This command will build the docker image from the Dockerfile and will be assigned the name gluster-fedora or gluster-centos respectively. ‘-t’ option is used to give a name to the image we built.

Once the image is built in either of the above two steps, now we can run the container with gluster daemon running. 

Before this, ensure the following directories are created on the host where docker is running:
 - /etc/glusterfs
 - /var/lib/glusterd
 - /var/log/glusterfs

Ensure all the above directories are empty to avoid any conflicts.

Also, ntp service like chronyd / ntpd service needs to be started in the host.
This way all the gluster containers started will be time synchronized.

Now run the following command:

~~~
$ docker run -v /etc/glusterfs:/etc/glusterfs:z -v /var/lib/glusterd:/var/lib/glusterd:z -v /var/log/glusterfs:/var/log/glusterfs:z -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d --privileged=true --net=host -v /dev/:/dev gluster/gluster-centos
~~~

( is either gluster-fedora or gluster-centos as per the configurations so far)

Where:
~~~
        --net=host        ( Optional: This option brings maximum network throughput for your storage container)

        --privileged=true ( If you are exposing the `/dev/` tree of host to the container to create bricks from the container)
~~~
Bind mounting of following directories enables:
~~~
        `/var/lib/glusterd`     : To make gluster metadata persistent in the host.
        `/var/log/glusterfs`    : To make gluster logs persistent in the host.
        `/etc/glusterfs`        : To make gluster configuration persistent in the host.
~~~

Systemd has been installed and is running in the container we maintain.

Once issued, this will boot up the Fedora or CentOS system and you have a container started with glusterd running in it.

##### Verify the container is running successfully:

~~~
$ docker ps -a

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
d273cc739c9d gluster/gluster-fedora:latest "/usr/sbin/init" 3 minutes ago Up 3 minutes 49157/tcp, 49161/tcp, 49158/tcp, 38466/tcp, 8080/tcp, 2049/tcp, 24007/tcp, 49152/tcp, 49162/tcp, 49156/tcp, 6010/tcp, 111/tcp, 49154/tcp, 443/tcp, 49160/tcp, 38468/tcp, 49159/tcp, 245/tcp, 49153/tcp, 6012/tcp, 38469/tcp, 6011/tcp, 38465/tcp, 0.0.0.0:49153->22/tcp angry_morse
Note the Container ID of the image and inspect the image to get the IP address. Say the Container ID of the image is d273cc739c9d , so to get the IP do:
~~~

##### To inspect the container:

~~~
$ docker inspect d273cc739c9d

"GlobalIPv6Address": "",
"GlobalIPv6PrefixLen": 0,
"IPAddress": "172.17.0.2",
"IPPrefixLen": 16,
"IPv6Gateway": "",
"LinkLocalIPv6Address": "fe80::42:acff:fe11:2",
"LinkLocalIPv6PrefixLen": 64,
The IP address is “172.17.0.2”

~~~

##### Get inside the container

~~~
$ docker exec -ti d273cc739c9d bash

-bash-4.3# ps aux |grep glusterd
root 34 0.0 0.0 448092 15800 ? Ssl 06:01 0:00 /usr/sbin/glusterd -p /var/run/glusterd.pid
root 159 0.0 0.0 112992 2224 pts/0 S+ 06:22 0:00 grep --color=auto glusterd

-bash-4.3# gluster peer status
Number of Peers: 0

-bash-4.3# gluster --version
~~~

That’s it!

Additional Ref# https://goo.gl/3031Mm

##### Capturing coredumps

/var/log/core directory is already added in the container.
Coredumps can be configured to be generated under /var/log/core directory.

User can copy the coredump(s) generated under /var/log/core/ directory
from the container to the host.

For example:
~~~
ssh <hostmachine>
sysctl -w kernel.core_pattern=/var/log/core/core_%e.%p
~~~

## Gluster Object Docker container:

### To pull gluster-s3:
~~~
$ docker pull gluster/gluster-s3
~~~

### To run gluster-s3 container:

On the host machine, mount one or more gluster volumes under the directory
`/mnt/gluster-object` with mountpoint name being same as that of the volume.

For example, if you have two gluster volumes named `test` and `test2`, they
should be mounted at `/mnt/gluster-object/test` and `/mnt/gluster-object/test2`
respectively. This directory on the host machine containing all the individual
glusterfs mounts is then bind-mounted inside the container. This avoids having
to bind mount individual gluster volumes.

The same needs to be updated in etc/sysconfig/swift-volumes.

For example(in swift-volumes):
S3_ACCOUNT='tv1'

Where tv1 is the volume name.

~~~
$ docker run -d --privileged  -v /sys/fs/cgroup/:/sys/fs/cgroup/:ro -p 8080:8080 -v /mnt/gluster-object:/mnt/gluster-object -e S3_ACCOUNT="tv1" -e S3_USER="admin" -e S3_PASSWORD="redhat" gluster/gluster-s3
~~~

Now, We can get/put objects into the gluster volume, using the gluster-s3 Docker container.
Refer this link[1] for testing.

[1] https://github.com/gluster/gluster-swift/blob/master/doc/markdown/quick_start_guide.md#using_swift


