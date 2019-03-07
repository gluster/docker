# Gluster Rsyslog Docker container:

This dockerfile is used to run a rsyslog service with specific configuration
and rulebase to parse gluster specific log files. The eventual objective is to
normalize the gluster specific log files and feed it to and elastic search
service to enable log search, analysis and visualization. This container is
based on Alpine Linux and is therefore lightweight and run as a sidecar
container in a [gcs](https://github.com/gluster/gcs) cluster along with
containers running [GD2](https://github.com/gluster/glusterd2).As of now only
GD2 log files are normalized to some extent.
