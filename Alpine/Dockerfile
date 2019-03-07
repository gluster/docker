FROM alpine:latest

ENV NAME="gluster-rsyslog" \
    DESC="Rsyslog for Gluster on Alpine" \
    VERSION=0 \
    RELEASE=1 \
    ARCH=x86_64 \
    container=docker

LABEL name="$NAME" \
      version="$VERSION" \
      architecture="$ARCH" \
      vendor="Red Hat, Inc" \
      summary="$DESC" \
      io.k8s.display-name="Gluster rsyslog service based on Alpine" \
      io.k8s.description="Gluster rsyslog service based on Alpine which includes rsyslog packages, configuration and rulebase to parse and normalize gluster logs." \
      description="Gluster rsyslog image is based on Alpine which includes rsyslog packages, configuration and rulebase to parse and normalize gluster logs." \
      maintainer="Sidharth Anupkrishnan <sanupkri@redhat.com>, Sridhar Seshasayee <sseshasa@redhat.com>"

RUN apk add --update rsyslog rsyslog-mmnormalize \
    && rm -rf /var/cache/apk/*

ADD rsyslog.conf /etc/rsyslog.conf
ADD gd2.rulebase /etc/rsyslog.d/gd2.rulebase

ENTRYPOINT ["rsyslogd", "-n"]
