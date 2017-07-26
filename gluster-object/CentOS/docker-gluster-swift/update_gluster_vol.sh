#!/bin/bash

# To update gluster volume name in swift-volumes, used by swift-gen-builders.service
if [[ -z "$GLUSTER_VOLUMES" || -z "$GLUSTER_USER" || -z "$GLUSTER_PASSWORD" ]]; then
        echo "You need to set GLUSTER_VOLUMES, GLUSTER_USER, GLUSTER_PASSWORD env variable"
        exit 1
else
        echo "GLUSTER_VOLUMES env variable is set. Update in swift-volumes"
        sed -i.bak '/^GLUSTER_VOLUMES=/s/=.*/='\""$GLUSTER_VOLUMES"\"'/' /etc/sysconfig/swift-volumes
	sed -i.bak '/^GLUSTER_USER=/s/=.*/='\""$GLUSTER_USER"\"'/' /etc/sysconfig/swift-volumes
	sed -i.bak '/^GLUSTER_PASSWORD=/s/=.*/='\""$GLUSTER_PASSWORD"\"'/' /etc/sysconfig/swift-volumes
fi

# Hand off to CMD
exec "$@"
