FROM centos:latest

MAINTAINER Humble Chirammal hchiramm@redhat.com

ENV container docker

RUN yum --setopt=tsflags=nodocs -y update; yum clean all;

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum --setopt=tsflags=nodocs -y install wget nfs-utils attr iputils iproute centos-release-gluster

RUN yum --setopt=tsflags=nodocs -y install epel-release

RUN yum --setopt=tsflags=nodocs -y install openssh-server openssh-clients ntp rsync tar cronie sudo xfsprogs glusterfs glusterfs-server glusterfs-geo-replication;yum clean all;

RUN sed -i '/Defaults    requiretty/c\#Defaults    requiretty' /etc/sudoers

# Changing the port of sshd to avoid conflicting with host sshd
RUN sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config

# Backing up gluster config as it overlaps when bind mounting.
RUN mkdir -p /etc/glusterfs_bkp /var/lib/glusterd_bkp /var/log/glusterfs_bkp;\
cp -r /etc/glusterfs/* /etc/glusterfs_bkp;\
cp -r /var/lib/glusterd/* /var/lib/glusterd_bkp;\
cp -r /var/log/glusterfs/* /var/log/glusterfs_bkp;

# Adding script to move the glusterfs config file to location
ADD gluster-setup.service /etc/systemd/system/gluster-setup.service
RUN chmod 644 /etc/systemd/system/gluster-setup.service

# Adding script to move the glusterfs config file to location
ADD gluster-setup.sh /usr/sbin/gluster-setup.sh
RUN chmod 500 /usr/sbin/gluster-setup.sh

RUN echo 'root:password' | chpasswd
VOLUME [ “/sys/fs/cgroup” ]

RUN systemctl disable nfs-server.service
RUN systemctl enable ntpd.service
RUN systemctl enable rpcbind.service
RUN systemctl enable glusterd.service
RUN systemctl enable gluster-setup.service

EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

CMD ["/usr/sbin/init"]
