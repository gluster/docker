This repo contain dockerfiles (CentOS, Fedora, Red Hat) for GlusterFS containers.

Although Setting up a glusterfs environment is a pretty simple and straight forward procedure, Gluster community do maintain docker images for gluster both in Fedora and CentOS in the docker hub for the ease of users. This blog is intented to walk the user through the steps of running GlusterFS with the help of docker.
The community maintains docker images GlusterFS release 3.6 in both Fedora-21 and CentOS-7. The following are the steps to build the GlusterFS docker images that we maintain:
To pull the docker image from the docker hub run the following command:
For GlusterFS-3.6 in Fedora-21

~~~
$ docker pull gluster/gluster-fedora

~~~
For GlusterFS-3.6 in CentOS-7

~~~
$ docker pull gluster/gluster-centos

~~~
This will fetch and build the docker image for you from the docker hub.
Alternatively, one could build the image from the Dockerfile directly. For this, one should pull the Gluster-Fedora Dockerfile from the source repository and build the image using that. For getting the source, One can make use of git:

~~~
$ git clone git@github.com:gluster/docker.git
~~~

This repository consists of Dockerfiles for GlusterFS built in both CentOS and Fedora distributions. Once you clone the repository, to build the image, run the following commands:
For Fedora,

~~~
$ docker build -t gluster-fedora docker/Fedora/Dockerfile

~~~
For CentOS,
~~~
$ docker build -t gluster-centos docker/CentOS/Dockerfile
~~~
This command will build the docker image from the Dockerfile you just cloned and will be assigned the name gluster-fedora or gluster-centos respectively. ‘-t’ option is used to give a name to the image we are about the build.
Once the image is built in either of the above two steps, we can now run the container with gluster daemon running. For this run the command:

~~~
$ docker run --privileged -ti -p 22 image name
~~~

( is either gluster-fedora or gluster-centos as per the configurations so far)

To detach this container you can press `Ctrl p + Ctrl q`

Systemd has been installed and is running in the container we maintain. This is to ensure that gluster daemon is up and running by the time we boot up our container and also to deal with the “Failed to get D-Bus connection” issue. To fix the issue Dan Walsh’s blog on the same matter has been the only resource: developerblog.redhat.com/2014/05/05/running-systemd-within-docker-container/
For systemd to run without crashing it is necessary to run the container in the privileged mode since systemd requires CAP_SYS_ADMIN capability. As per the help of docker run shows, ‘-t’ option is given to alocate a psedo-TTY and’i stands for the interactive mode which keeps STDIN open even if not attached. The port 22 has been published to the host so that one can ssh into the container that will be running once this command is issued. In the docker file, the password for the root has been changed to ‘password’ for user to ssh into the running container.
One issued, this will boot up the Fedora or CentOS system and you have a container started with glusterd running in it. Now to login to the container, one need to inspect the IP of the container running. To get the ID of the container, one can do:

~~~
$ docker ps -a

CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
d273cc739c9d gluster/gluster-fedora:latest "/usr/sbin/init" 3 minutes ago Up 3 minutes 49157/tcp, 49161/tcp, 49158/tcp, 38466/tcp, 8080/tcp, 2049/tcp, 24007/tcp, 49152/tcp, 49162/tcp, 49156/tcp, 6010/tcp, 111/tcp, 49154/tcp, 443/tcp, 49160/tcp, 38468/tcp, 49159/tcp, 245/tcp, 49153/tcp, 6012/tcp, 38469/tcp, 6011/tcp, 38465/tcp, 0.0.0.0:49153->22/tcp angry_morse
Note the Container ID of the image and inspect the image to get the IP address. Say the Container ID of the image is d273cc739c9d , so to get the IP do:
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
Once we have got the IP, ssh into the container:

~~~

$ ssh root@IP address
The password will be ‘password’ as specified in the dockerfile. Make sure the password is changed immediately.
[ ~]# ssh root@172.17.0.2
root@172.17.0.2's password:
System is booting up. See pam_nologin(8)
Last login: Mon May 4 06:22:34 2015 from 172.17.42.1
-bash-4.3# ps aux |grep glusterd
root 34 0.0 0.0 448092 15800 ? Ssl 06:01 0:00 /usr/sbin/glusterd -p /var/run/glusterd.pid
root 159 0.0 0.0 112992 2224 pts/0 S+ 06:22 0:00 grep --color=auto glusterd
-bash-4.3# gluster peer status
Number of Peers: 0
-bash-4.3# gluster --version
glusterfs 3.6.3 built on Apr 23 2015 16:12:34
Repository revision: git.gluster.com/glusterfs.git
Copyright (c) 2006-2011 Gluster Inc.
GlusterFS comes with ABSOLUTELY NO WARRANTY.
You may redistribute copies of GlusterFS under the terms of the GNU General Public License.
-bash-4.3#

~~~
That’s it!
