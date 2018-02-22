FROM centos:7

MAINTAINER Humble Chirammal hchiramm@redhat.com Mohamed Ashiq Liyazudeen mliyazud@redhat.com

ENV container docker

LABEL architecture="x86_64" \
      name="gluster/gluster-centos" \
      version="3.10" \
      vendor="CentOS Community" \
      summary="This image has a running glusterfs service ( CentOS 7 + Gluster 3.10)" \
      io.k8s.display-name="Gluster 3.10 based on CentOS 7" \
      io.k8s.description="Gluster Image is based on CentOS Image which is a scalable network filesystem. Using common off-the-shelf hardware, you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      description="Gluster Image is based on CentOS Image which is a scalable network filesystem. Using common off-the-shelf hardware, you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      io.openshift.tags="gluster,glusterfs,glusterfs-centos"

RUN yum --setopt=tsflags=nodocs -y update; yum clean all;

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum --setopt=tsflags=nodocs -y install wget nfs-utils attr iputils iproute centos-release-gluster310

RUN yum --setopt=tsflags=nodocs -y install openssh-server openssh-clients ntp rsync tar cronie sudo xfsprogs glusterfs glusterfs-server glusterfs-geo-replication;yum clean all;

RUN sed -i '/Defaults    requiretty/c\#Defaults    requiretty' /etc/sudoers

# Changing the port of sshd to avoid conflicting with host sshd
RUN sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config

# Backing up gluster config as it overlaps when bind mounting.
RUN mkdir -p /etc/glusterfs_bkp /var/lib/glusterd_bkp /var/log/glusterfs_bkp;\
cp -r /etc/glusterfs/* /etc/glusterfs_bkp;\
cp -r /var/lib/glusterd/* /var/lib/glusterd_bkp;\
cp -r /var/log/glusterfs/* /var/log/glusterfs_bkp;

# Configure LVM to create LVs and snapshots
RUN sed -i.save -e "s#udev_sync = 1#udev_sync = 0#" \
   -e "s#udev_rules = 1#udev_rules = 0#" \
   -e "s#use_lvmetad = 1#use_lvmetad = 0#" /etc/lvm/lvm.conf

# Adding script to move the glusterfs config file to location
ADD gluster-setup.service /etc/systemd/system/gluster-setup.service
RUN chmod 644 /etc/systemd/system/gluster-setup.service

# Adding script to move the glusterfs config file to location
ADD gluster-setup.sh /usr/sbin/gluster-setup.sh
RUN chmod 500 /usr/sbin/gluster-setup.sh

#RUN echo 'root:password' | chpasswd
VOLUME [ “/sys/fs/cgroup” ]

RUN systemctl disable nfs-server.service
RUN systemctl enable ntpd.service
RUN systemctl enable rpcbind.service
RUN systemctl enable glusterd.service
RUN systemctl enable gluster-setup.service

EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

CMD ["/usr/sbin/init"]
