FROM centos:latest

MAINTAINER Humble Chirammal hchiramm@redhat.com

ENV container docker
VOLUME [ "/sys/fs/cgroup", "/etc/glusterfs", "/var/lib/glusterd", "/var/log/glusterfs", "/var/lib/heketi" ]
EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

ADD gluster-setup.service /etc/systemd/system/gluster-setup.service
ADD gluster-setup.sh /usr/sbin/gluster-setup.sh

RUN yum --setopt=tsflags=nodocs -y install centos-release-gluster epel-release && \
    yum --setopt=tsflags=nodocs -y install wget nfs-utils attr iputils iproute \
        openssh-server openssh-clients ntp rsync tar cronie sudo xfsprogs \
        glusterfs glusterfs-server glusterfs-geo-replication && \
    yum clean all && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/* && \
    sed -i '/Defaults    requiretty/c\#Defaults    requiretty' /etc/sudoers && \
    sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config && \
    for dir in /etc/glusterfs /var/lib/glusterd /var/log/glusterfs; do \
        mkdir -p ${dir}_bkp && \
        cp -r $dir/* ${dir}_bkp ; \
    done && \
    chmod 644 /etc/systemd/system/gluster-setup.service && \
    chmod 500 /usr/sbin/gluster-setup.sh && \
    systemctl disable nfs-server.service && \
    systemctl enable glusterd.service gluster-setup.service && \
    echo 'root:password' | chpasswd

CMD ["/usr/sbin/init"]
