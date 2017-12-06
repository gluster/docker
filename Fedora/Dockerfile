FROM registry.fedoraproject.org/fedora

ENV NAME="gluster-fedora" \
    DESC="GlusterFS on Fedora" \
    VERSION=0 \
    RELEASE=1 \
    ARCH=x86_64 \
    REPO="$FGC" \
    container=docker

LABEL name="$REPO/$NAME" \
      version="$VERSION" \
      release="$RELEASE.$DISTTAG" \
      architecture="$ARCH" \
      vendor="Red Hat, Inc" \
      summary="$DESC" \
      usage="docker run -d -P --tmpfs /run --tmpfs /tmp -v /sys/fs/cgroup:/sys/fs/cgroup $REPO/$NAME" \
      io.k8s.display-name="$DESC" \
      io.k8s.description="GlusterFS is a distributed and scalable network filesystem. Using common, off-the-shelf hardware you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      io.openshift.tags="gluster,glusterfs,gluster-fedora" \
      com.redhat.component="$NAME" \
      maintainer="Jose A. Rivera <jarrpa@redhat.com>, Humble Chirammal <hchiramm@redhat.com>"

VOLUME [ "/sys/fs/cgroup/" ]

ADD https://github.com/gluster/gluster-containers/blob/master/README.md /README.md

COPY gluster-setup.sh gluster-brickmultiplex.service gluster-brickmultiplex.sh gluster-setup.service /

RUN dnf -y update && \
    sed -i "s/LANG/\#LANG/g" /etc/locale.conf && \
    dnf -y install systemd-udev ntp glusterfs-server dbus-python nfs-utils attr iputils iproute glusterfs-geo-replication openssh-server openssh-clients cronie tar rsync sos sudo xfsprogs && \
    dnf clean all && \
    sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config && \
    sed -i 's/Requires\=rpcbind\.service//g' /usr/lib/systemd/system/glusterd.service && \
    sed -i 's/rpcbind\.service/gluster-setup\.service/g' /usr/lib/systemd/system/glusterd.service && \
    sed -i.save -e "s#udev_sync = 1#udev_sync = 0#" -e "s#udev_rules = 1#udev_rules = 0#" -e "s#use_lvmetad = 1#use_lvmetad = 0#" /etc/lvm/lvm.conf && \
    # Back up the default/base configuration. The target directories get
    # overwritten with the directories from the host which are initially
    # empty.
    mkdir -p /etc/glusterfs_bkp /var/lib/glusterd_bkp /var/log/glusterfs_bkp && \
    cp -r /etc/glusterfs/* /etc/glusterfs_bkp && \
    cp -r /var/lib/glusterd/* /var/lib/glusterd_bkp && \
    cp -r /var/log/glusterfs/* /var/log/glusterfs_bkp && \
    mv /gluster-setup.sh /usr/sbin/gluster-setup.sh && \
    mv /gluster-brickmultiplex.service /etc/systemd/system/gluster-brickmultiplex.service && \
    mv /gluster-brickmultiplex.sh /usr/sbin/gluster-brickmultiplex.sh && \
    mv /gluster-setup.service /etc/systemd/system/gluster-setup.service && \
    chmod 644 /etc/systemd/system/gluster-setup.service && \
    chmod 500 /usr/sbin/gluster-setup.sh && \
    ln -s /usr/sbin/gluster-setup.sh /usr/sbin/setup.sh && \
    chmod 644 /etc/systemd/system/gluster-brickmultiplex.service && \
    chmod 500 /usr/sbin/gluster-brickmultiplex.sh && \
    systemctl mask getty.target && \
    systemctl disable systemd-udev-trigger.service && \
    systemctl disable systemd-udevd.service && \
    systemctl disable nfs-server.service && \
    systemctl enable rpcbind.service && \
    systemctl enable sshd.service && \
    systemctl enable ntpd.service && \
    systemctl enable gluster-setup.service && \
    systemctl enable gluster-brickmultiplex.service && \
    systemctl enable glusterd.service

EXPOSE 2222 111 245 443 24006 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

CMD ["/usr/sbin/init"]
