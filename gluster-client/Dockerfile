FROM fedora

MAINTAINER Humble Devassy Chirammal  <hchiramm@redhat.com>

LABEL architecture="x86_64" \
      name="gluster/glusterfs-client" \
      version="3.10" \
      vendor="Red Hat, Inc" \
      summary="This image has a running glusterfs service ( Fedora + Gluster 3.10 client)" \
      io.k8s.display-name="Gluster 3.10 client based on Fedora" \
      io.k8s.description="Gluster Client Image is based on Fedora Image which is used to mount a glusterfs volume." \
      description="Gluster Client Image is based on Fedora Image which is used to mount a glusterfs volume." \
      io.openshift.tags="gluster,glusterfs,glusterfs-client"

ENV container docker

RUN sed -i "s/LANG/\#LANG/g" /etc/locale.conf
RUN dnf --setopt=tsflags=nodocs -y update &&\
dnf --setopt=tsflags=nodocs -y install wget nfs-utils attr iputils iproute &&\
dnf install -y glusterfs-fuse &&\
dnf clean all

# Directory for coredumps. Note,kernel.core_pattern must be configured as such
RUN mkdir -p /var/log/core

CMD ["/bin/bash"]
