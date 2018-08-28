#!/bin/bash

if ! systemctl -q is-active glusterd.service; then
   # glusterd not active
   exit 1
fi

# Disk full
current_usage=$( df --output=pcent  '/var/lib/glusterd' | tail -n1  | awk {'print $1'} )
max_usage=99%
if [ "${current_usage%?}" -ge "${max_usage%?}" ]; then
    # echo "Disk alert ${current_usage} more than ${max_usage}"
    exit 1
fi

# All is well
exit 0
