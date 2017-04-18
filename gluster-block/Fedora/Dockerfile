FROM fedora

MAINTAINER Vijay Bellur vbellur@redhat.com

ENV container docker

RUN yum -y update && yum clean all

RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum --setopt=tsflags=nodocs -y install wget nfs-utils iputils iproute attr glusterfs glusterfs-server glusterfs-geo-replication openssh-server tcmu-runner dnf-plugins-core; yum clean all
RUN dnf config-manager --add-repo https://download.gluster.org/pub/gluster/gluster-block/gluster-block.repo
RUN dnf install -y gluster-block

RUN echo 'root:password' | chpasswd
VOLUME [ "/sys/fs/cgroup" ]

EXPOSE 22 111 245 443 24007 24006 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162 49163

RUN systemctl disable nfs-server.service
RUN systemctl enable rpcbind.service
RUN systemctl enable glusterd.service
RUN systemctl enable gluster-blockd.service
CMD ["/usr/sbin/init"]

