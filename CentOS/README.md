This dockerfile can be used to build a CentOS Gluster Container.

## Automounting bricks

If you volume-mount /var/lib/heketi/fstab, the container will mount all bricks in that file.

## Enabling additional services

By default, only glusterd will be enabled. To enable other services, set the following env variables to `yes`.

 * `ENABLE_NTPD`
 * `ENABLE_SSHD`
 * `ENABLE_RPCBIND`
