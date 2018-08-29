#!/bin/bash

# Disk full
while true
do
        # sleep early to get glusterd settled
        sleep $1
        current_usage=$( df --output=pcent  '/var/lib/glusterd' | tail -n1  | awk {'print $1'} )
        max_usage=99%
        if [ "${current_usage%?}" -ge "${max_usage%?}" ]; then
                echo "$(date) - $(basename $0): Running out of space in /var/lib/glusterd"
                echo "$(date) - $(basename $0): Stopping glusterd"
                systemctl stop glusterd.service
                echo "$(date) -$(basename $0): Stopped glusterd"
                break
        fi
done
