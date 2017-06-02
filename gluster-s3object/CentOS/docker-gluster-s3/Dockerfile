FROM centos:7
MAINTAINER Prashanth Pai <ppai@redhat.com>

# centos-release-openstack-kilo package resides in the extras repo.
# All subsequent actual packages come from the CentOS Cloud SIG repo:
# http://mirror.centos.org/centos/7/cloud/x86_64/

# Install PACO servers and S3 middleware.
# Install gluster-swift dependencies. To be removed when RPMs become available.
# Clean downloaded packages and index

LABEL architecture="x86_64" \
      name="gluster/gluster-swift" \
      version="kilo" \
      vendor="Red Hat, Inc" \
      summary="This image has a running gluster-swift service ( centos 7 + gluster-swift)" \
      io.k8s.display-name="gluster-swift based on centos 7" \
      io.k8s.description="gluster-swift image is based on centos image which enables files and directories created on GlusterFS to be accessed as objects via the Swift and S3 API." \
      description="gluster-swift image is based on centos image which enables files and directories created on GlusterFS to be accessed as objects via the Swift and S3 API." \
      io.openshift.tags="gluster,glusterfs,gluster-swift"

RUN yum -v --setopt=tsflags=nodocs -y update && \
    yum -v --setopt=tsflags=nodocs -y install \
        centos-release-openstack-kilo \
        epel-release && \
    yum -v --setopt=tsflags=nodocs -y install \
        openstack-swift openstack-swift-{proxy,account,container,object,plugin-swift3} \
        git memcached python-prettytable && \
    yum -y install systemd && \
        (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
        rm -f /lib/systemd/system/multi-user.target.wants/*;\
        rm -f /etc/systemd/system/*.wants/*;\
        rm -f /lib/systemd/system/local-fs.target.wants/*; \
        rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
        rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
        rm -f /lib/systemd/system/basic.target.wants/*;\
        rm -f /lib/systemd/system/anaconda.target.wants/* && \
    yum -y clean all

# Install gluster-swift from source.
# TODO: When gluster-swift is shipped as RPM, just use that.
RUN git clone git://review.gluster.org/gluster-swift /tmp/gluster-swift && \
    cd /tmp/gluster-swift && \
    python setup.py install && \
    cd -

# Gluster volumes will be mounted *under* this directory.
VOLUME /mnt/gluster-object

# Copy systemd scripts
COPY swift-gen-builders.service /lib/systemd/system/
COPY swift-proxy.service /lib/systemd/system/
COPY swift-account.service /lib/systemd/system/
COPY swift-container.service /lib/systemd/system/
COPY swift-object.service /lib/systemd/system/

# Replace openstack swift conf files with local gluster-swift ones
COPY etc/swift/* /etc/swift/

# To update volume name used by swift-gen-builders service
COPY update_gluster_vol.sh /usr/local/bin/update_gluster_vol.sh
RUN chmod +x /usr/local/bin/update_gluster_vol.sh

# volumes to be exposed as object storage is present in swift-volumes file
COPY etc/sysconfig/swift-volumes /etc/sysconfig/swift-volumes

# The proxy server listens on port 8080
EXPOSE 8080

RUN echo 'root:password' | chpasswd
VOLUME [ "/sys/fs/cgroup" ]

RUN systemctl enable swift-gen-builders.service;\
systemctl enable memcached.service;\
systemctl enable swift-proxy.service;\
systemctl enable swift-account.service;\
systemctl enable swift-container.service;\
systemctl enable swift-object.service;

ENTRYPOINT ["/usr/local/bin/update_gluster_vol.sh"]
CMD ["/usr/sbin/init"]
