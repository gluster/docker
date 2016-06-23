#!/bin/bash -e

###
# Description: Script to move the glusterfs initial setup to bind mounted directories of Atomic Host.
# Copyright (c) 2016 Red Hat, Inc. <http://www.redhat.com>
#
# This file is part of GlusterFS.
#
# This file is licensed to you under your choice of the GNU Lesser
# General Public License, version 3 or any later version (LGPLv3 or
# later), or the GNU General Public License, version 2 (GPLv2), in all
# cases as published by the Free Software Foundation.
###

DIRS_TO_RESTORE="/etc/glusterfs /var/log/glusterfs /var/lib/glusterd"

err() {
  echo -ne $* 1>&2
}

main () {
  if [ -f /var/lib/heketi/fstab ]
  then
        mount -a --fstab /var/lib/heketi/fstab
        if [ $? -eq 1 ]
        then
              err "mount failed"
              exit 1
        fi
        echo "Mount Successful"
  else
        echo "heketi-fstab not found"
  fi

  for dir in $DIRS_TO_RESTORE
  do
    if test "$(ls $dir)"
    then
      echo "$dir is not empty"
    else
      if ! cp -r ${dir}_bkp/* $dir
      then
          err "Failed to copy $dir"
          exit 1
      fi
    fi
  done

  echo "Script Ran Successfully"
}
main
