#!/bin/bash

# glusterd not active 
if `systemctl -q is-failed glusterd.service`; then
   exit 0;
fi

# Disk full
current_usage=$( df -h  '/var/lib/glusterd' | grep var  | awk {'print $5'} )
max_usage=99%
if [ "${current_usage%?}" -ge "${max_usage%?}" ]; then
    # echo "Disk alert ${current_usage} more than ${max_usage}"
    exit 0;
fi

# All is well
exit 1;
