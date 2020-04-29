FROM centos:7

MAINTAINER Humble Chirammal hchiramm@redhat.com Saravanakumar Arumugam sarumuga@redhat.com

ENV container docker

ENV ARCH "x86_64"
LABEL architecture="$ARCH" \
      name="gluster/gluster-centos" \
      version="latest" \
      vendor="CentOS Community" \
      summary="This image has a running glusterfs service (CentOS 7 + latest Gluster)" \
      io.k8s.display-name="Gluster server based on CentOS 7" \
      io.k8s.description="Gluster Image is based on CentOS Image which is a scalable network filesystem. Using common off-the-shelf hardware, you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      description="Gluster Image is based on CentOS Image which is a scalable network filesystem. Using common off-the-shelf hardware, you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      io.openshift.tags="gluster,glusterfs,glusterfs-centos"

RUN yum --setopt=tsflags=nodocs -y update && yum install -y centos-release-gluster && yum clean all && \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
rm -f /lib/systemd/system/multi-user.target.wants/* &&\
rm -f /etc/systemd/system/*.wants/* &&\
rm -f /lib/systemd/system/local-fs.target.wants/* && \
rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
rm -f /lib/systemd/system/basic.target.wants/* &&\
rm -f /lib/systemd/system/anaconda.target.wants/* &&\
yum --setopt=tsflags=nodocs -y install nfs-utils && \
yum --setopt=tsflags=nodocs -y install attr  && \
yum --setopt=tsflags=nodocs -y install iputils  && \
yum --setopt=tsflags=nodocs -y install iproute  && \
yum --setopt=tsflags=nodocs -y install openssh-server  && \
yum --setopt=tsflags=nodocs -y install openssh-clients  && \
yum --setopt=tsflags=nodocs -y install rsync  && \
yum --setopt=tsflags=nodocs -y install tar  && \
yum --setopt=tsflags=nodocs -y install cronie  && \
yum --setopt=tsflags=nodocs -y install xfsprogs  && \
yum --setopt=tsflags=nodocs -y install glusterfs  && \
yum --setopt=tsflags=nodocs -y install glusterfs-server  && \
yum --setopt=tsflags=nodocs -y install glusterfs-rdma  && \
yum --setopt=tsflags=nodocs -y install gluster-block  && \
yum --setopt=tsflags=nodocs -y install glusterfs-geo-replication && yum clean all && \
sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config && \
sed -i 's/Requires\=rpcbind\.service//g' /usr/lib/systemd/system/glusterd.service && \
sed -i 's/rpcbind\.service/gluster-setup\.service/g' /usr/lib/systemd/system/glusterd.service && \
sed -i 's/rpcbind\.service//g' /usr/lib/systemd/system/gluster-blockd.service && \
mkdir -p /etc/glusterfs_bkp /var/lib/glusterd_bkp /var/log/glusterfs_bkp &&\
cp -r /etc/glusterfs/* /etc/glusterfs_bkp &&\
cp -r /var/lib/glusterd/* /var/lib/glusterd_bkp &&\
cp -r /var/log/glusterfs/* /var/log/glusterfs_bkp && \
mkdir -p /var/log/core;

# do not run udev (if needed, bind-mount /run/udev instead?)
RUN true \
    && systemctl mask systemd-udev-trigger.service \
    && systemctl mask systemd-udevd.service \
    && systemctl mask systemd-udevd.socket \
    && systemctl mask systemd-udevd-kernel.socket \
    && true

# use lvmetad from the host, dont run it in the container
# don't wait for udev to manage the /dev entries, disable udev_sync, udev_rules in lvm.conf
VOLUME [ "/run/lvm" ]
RUN true \
    && systemctl mask lvm2-lvmetad.service \
    && systemctl mask lvm2-lvmetad.socket \
    && sed -i 's/^\sudev_rules\s*=\s*1/udev_rules = 0/' /etc/lvm/lvm.conf \
    && sed -i 's/^\sudev_sync\s*=\s*1/udev_sync= 0/' /etc/lvm/lvm.conf \
    && sed -i 's/^\sobtain_device_list_from_udev\s*=\s*1/obtain_device_list_from_udev = 0/' /etc/lvm/lvm.conf \
    && true

# prevent dmeventd from running in the container, it may cause conflicts with
# the service running on the host
# monitoring of activated LVs can not be done inside the container
RUN true \
    && systemctl mask dm-event.service \
    && systemctl disable dm-event.socket \
    && systemctl mask dm-event.socket \
    && systemctl disable lvm2-monitor.service \
    && systemctl mask lvm2-monitor.service \
    && sed -i 's/^\smonitoring\s*=\s*1/monitoring = 0/' /etc/lvm/lvm.conf \
    && true

# mask services that aren't required in the container and/or might interfere
RUN true \
    && systemctl mask getty.target \
    && systemctl mask systemd-journal-flush.service \
    && systemctl mask systemd-journald.service \
    && systemctl mask systemd-journald.socket \
    && systemctl mask systemd-logind.service \
    && systemctl mask rpcbind.socket \
    && true


VOLUME [ "/sys/fs/cgroup" ]
ADD gluster-fake-disk.service /etc/systemd/system/gluster-fake-disk.service
ADD fake-disk.sh /usr/libexec/gluster/fake-disk.sh
ADD gluster-setup.service /etc/systemd/system/gluster-setup.service
ADD gluster-setup.sh /usr/sbin/gluster-setup.sh
ADD gluster-block-setup.service /etc/systemd/system/gluster-block-setup.service
ADD gluster-block-setup.sh /usr/sbin/gluster-block-setup.sh
ADD update-params.sh /usr/local/bin/update-params.sh
ADD status-probe.sh /usr/local/bin/status-probe.sh
ADD tcmu-runner-params /etc/sysconfig/tcmu-runner-params
ADD gluster-check-diskspace.service  /etc/systemd/system/gluster-check-diskspace.service
ADD check_diskspace.sh /usr/local/bin/check_diskspace.sh
ADD exec-on-host.sh /usr/sbin/exec-on-host

RUN chmod 644 /etc/systemd/system/gluster-setup.service && \
chmod 644 /etc/systemd/system/gluster-check-diskspace.service && \
chmod 755 /usr/libexec/gluster/fake-disk.sh && \
chmod 500 /usr/sbin/gluster-setup.sh && \
chmod 644 /etc/systemd/system/gluster-block-setup.service && \
chmod 500 /usr/sbin/gluster-block-setup.sh && \
chmod +x /usr/local/bin/update-params.sh && \
chmod +x /usr/local/bin/status-probe.sh && \
chmod +x /usr/local/bin/check_diskspace.sh && \
systemctl disable nfs-server.service && \
systemctl enable gluster-fake-disk.service && \
systemctl enable gluster-setup.service && \
systemctl enable gluster-block-setup.service && \
systemctl enable gluster-blockd.service && \
systemctl enable glusterd.service && \
systemctl enable gluster-check-diskspace.service

EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

ENTRYPOINT ["/usr/local/bin/update-params.sh"]
CMD ["/usr/sbin/init"]
