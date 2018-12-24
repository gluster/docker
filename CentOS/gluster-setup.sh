#!/bin/bash

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

main () {
  GLUSTERFS_CONF_DIR="/etc/glusterfs"
  GLUSTERFS_LOG_DIR="/var/log/glusterfs"
  GLUSTERFS_META_DIR="/var/lib/glusterd"
  GLUSTERFS_LOG_CONT_DIR="/var/log/glusterfs/container"
  GLUSTERFS_CUSTOM_FSTAB="/var/lib/heketi/fstab"

  mkdir $GLUSTERFS_LOG_CONT_DIR
  for i in $GLUSTERFS_CONF_DIR $GLUSTERFS_LOG_DIR $GLUSTERFS_META_DIR
  do
    if test "$(ls $i)"
    then
          echo "$i is not empty"
    else
          bkp=$i"_bkp"
          cp -af $bkp/* $i
          if [ $? -eq 1 ]
          then
                echo "Failed to copy $i"
                exit 1
          fi
          ls -R $i > ${GLUSTERFS_LOG_CONT_DIR}/${i}_ls
    fi
  done

  if test "$(ls $GLUSTERFS_LOG_CONT_DIR)"
  then
            echo "" > $GLUSTERFS_LOG_CONT_DIR/brickattr
            echo "" > $GLUSTERFS_LOG_CONT_DIR/failed_bricks
            echo "" > $GLUSTERFS_LOG_CONT_DIR/lvscan
            echo "" > $GLUSTERFS_LOG_CONT_DIR/mountfstab
  else
        mkdir $GLUSTERFS_LOG_CONT_DIR
        echo "" > $GLUSTERFS_LOG_CONT_DIR/brickattr
        echo "" > $GLUSTERFS_LOG_CONT_DIR/failed_bricks
  fi
  if test "$(ls $GLUSTERFS_CUSTOM_FSTAB)"
  then
        sleep 5
        pvscan > $GLUSTERFS_LOG_CONT_DIR/pvscan
        vgscan > $GLUSTERFS_LOG_CONT_DIR/vgscan
        lvscan > $GLUSTERFS_LOG_CONT_DIR/lvscan
        vgchange -ay > $GLUSTERFS_LOG_CONT_DIR/vgchange

        mount -a --fstab $GLUSTERFS_CUSTOM_FSTAB &> $GLUSTERFS_LOG_CONT_DIR/mountfstab
        sts=$?
        if [ $sts -eq 1 -o $sts -eq 2 -o $sts -eq 4 ]
        then
              echo "mount command exited with code ${sts}" >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
              exit 1
        fi
	if [ $sts -ne 0 ]
	then
	      echo "mount command non-fatal error with ${sts}" >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
	else
              echo "Mount command Successful" >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
	fi
        sleep 40
        cut -f 2 -d " " $GLUSTERFS_CUSTOM_FSTAB | while read -r line
        do
              if grep -qs "$line" /proc/mounts; then
                   echo "$line mounted." >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
                   if test "ls $line/brick"
                   then
                         echo "$line/brick is present" >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
                         getfattr -d -m . -e hex "$line"/brick >> $GLUSTERFS_LOG_CONT_DIR/brickattr
                   else
                         echo "$line/brick is not present" >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
                         sleep 1
                   fi
              else
		   grep "$line" $GLUSTERFS_CUSTOM_FSTAB >> $GLUSTERFS_LOG_CONT_DIR/failed_bricks
                   echo "$line not mounted." >> $GLUSTERFS_LOG_CONT_DIR/mountfstab
                   sleep 0.5
             fi
        done
        if [ "$((cat $GLUSTERFS_LOG_CONT_DIR/failed_bricks | wc -l) )" -gt 1 ]
        then
              vgscan --mknodes > $GLUSTERFS_LOG_CONT_DIR/vgscan_mknodes
              sleep 10
              mount -a --fstab $GLUSTERFS_LOG_CONT_DIR/failed_bricks
        fi
  else
        echo "heketi-fstab not found"
  fi

  echo "Script Ran Successfully"
  exit 0
}
main
