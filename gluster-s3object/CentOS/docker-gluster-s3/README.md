
# docker-gluster-swift
docker-gluster-swift is to provide object interface for a Gluster volume.

Let us see how to run gluster-swift inside a docker container.

## Building

```bash
# docker build --rm --tag gluster-swift .
```

## Running

On the host machine, mount one or more gluster volumes under the directory
`/mnt/gluster-object` with mountpoint name being same as that of the volume.

For example, if you have two gluster volumes named `test` and `test2`, they
should be mounted at `/mnt/gluster-object/test` and `/mnt/gluster-object/test2`
respectively. This directory on the host machine containing all the individual
glusterfs mounts is then bind-mounted inside the container. This avoids having
to bind mount individual gluster volumes.

The same needs to be updated in etc/sysconfig/swift-volumes.
For example(in swift-volumes):
GLUSTER_VOLUMES='tv1'

Where tv1 is the volume name.

**Example:**

```bash
# docker run -d --privileged  -v /sys/fs/cgroup/:/sys/fs/cgroup/:ro -p 8080:8080 -v /mnt/gluster-object:/mnt/gluster-object    gluster-swift
```

If you have selinux set to enforced on the host machine, refer to the
Troubleshooting section below before running the container.

**Note:**

~~~
-d : Runs the container in the background.
-p : Publishes the container's port to the host port. They need not be the same.
     If host port is omitted, a random port will be mapped. So you can run
     multiple instances of the container, each serving on a different port on
     the same host machine.
-v : Bind mount a host path inside the container.
-e : Set and pass environment variable. In our case, provide a list of volumes
     to be exported over object inerface by setting GLUSTER_VOLUMES environment
     variable.
~~~

### Custom deployment

You can provide your own configuration files and ring files and have the
swift processes running inside container use those. This can be done by
placing your conf files and ring files in a directory on your host machine
and then bind-mounting it inside the container at `/etc/swift`.

**Example:**

Assuming you have conf files and ring files present at `/tmp/swift` on the
machine, you can spawn the container as follows:

```bash
# docker run -d -p 8080:8080 -v /tmp/swift:/etc/swift -v /mnt/gluster-object:/mnt/gluster-object prashanthpai/gluster-swift:dev
```

If the host machine has SELinux set to enforced:

```bash
# chcon -Rt svirt_sandbox_file_t /tmp/swift
```

### Troubleshooting

**SELinux**

When a volume is bind mounted inside the container, you'll need blessings of
SELinux on the host machine. Otherwise, the application inside the container
won't be able to access the volume. Example:

```bash
[root@f24 ~]# docker exec -i -t nostalgic_goodall /bin/bash
[root@042abf4acc4d /]# ls /mnt/gluster-object/
ls: cannot open directory /mnt/gluster-object/: Permission denied
```

Ideally, running this command on host machine should work:

```bash
# chcon -Rt svirt_sandbox_file_t /mnt/gluster-object
```

However, glusterfs does not support setting of SELinux contexts [yet][1].
You can always set SELinux to permissive on host machine by running
`setenforce 0` or run container in privileged mode (`--privileged=true`).
I don't like either. A better workaround would be to mount the glusterfs
volumes on host machine as shown in following example:

[1]: https://bugzilla.redhat.com/show_bug.cgi?id=1252627

```bash
mount -t glusterfs -o selinux,context="system_u:object_r:svirt_sandbox_file_t:s0" `hostname`:test /mnt/gluster-object/test
```

### TODO

* Install gluster-swift from RPMs. (Currently installed from source)
