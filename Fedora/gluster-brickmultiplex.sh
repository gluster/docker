#!/bin/bash

###
# Description: Script to enable brick multiplexing in gluster.
# Copyright (c) 2017 Red Hat, Inc. <http://www.redhat.com>
#
# This file is part of GlusterFS.
#
# This file is licensed to you under your choice of the GNU Lesser
# General Public License, version 3 or any later version (LGPLv3 or
# later), or the GNU General Public License, version 2 (GPLv2), in all
# cases as published by the Free Software Foundation.
###

main () {
  GLUSTERFS_CONF_DIR="/etc/glusterfs"
  GLUSTERFS_LOG_DIR="/var/log/glusterfs"
  GLUSTERFS_META_DIR="/var/lib/glusterd"
  GLUSTERFS_LOG_CONT_DIR="/var/log/glusterfs/container"
  GLUSTERFS_CUSTOM_FSTAB="/var/lib/heketi/fstab"

  GLUSTER_BRICKMULTIPLEX=${GLUSTER_BRICKMULTIPLEX-yes}

  case "$GLUSTER_BRICKMULTIPLEX" in
    [nN] | [nN][Oo] )
      gluster v info | grep 'cluster.brick-multiplex: off' > $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
      if [[ ${?} == 0 ]]; then
        echo "cluster brick-multiplexing already disabled." >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
        exit 0
      fi

      gluster --mode=script volume set all cluster.brick-multiplex off >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
      if [[ ${?} != 0 ]]; then
        echo "cluster brick-multiplexing set failed." >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
        exit 1
      fi

      systemctl restart glusterd
      if [[ ${?} != 0 ]]; then
        echo "Restarting glusterd failed." >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
        exit 1
      fi

      echo "Brick Multiplexing Successfully Disabled"
      exit 0
      ;;
    [yY] | [yY][Ee][Ss] )
      gluster v info | grep 'cluster.brick-multiplex: on' > $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
      if [[ ${?} == 0 ]]; then
        echo "cluster brick-multiplexing already set." >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
        exit 0
      fi

      gluster --mode=script volume set all cluster.brick-multiplex on >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
      if [[ ${?} != 0 ]]; then
        echo "cluster brick-multiplexing set failed." >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
        exit 1
      fi

      systemctl restart glusterd
      if [[ ${?} != 0 ]]; then
        echo "Restarting glusterd failed." >> $GLUSTERFS_LOG_CONT_DIR/brickmultiplexing
        exit 1
      fi

      echo "Brick Multiplexing Successfully Enabled"
      exit 0
      ;;
    *) echo "Invalid input"
      ;;
  esac
}

main
