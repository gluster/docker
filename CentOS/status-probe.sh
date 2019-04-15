#!/bin/bash
#
# Return overall status of the glusterfs container
#

: ${GLUSTER_BLOCK_ENABLED:=1}
: ${GLUSTER_BLOCKD_STATUS_PROBE_ENABLE:=1}

require() {
    if ! "$@" ; then
        echo "failed check: $*" >&2
        exit 1
    fi
}

filesystem_used_under_limit() {
    path="$1"
    max_used="$2"
    curr_used="$(df --output=pcent "$path" | tail -n1  | awk '{print $1}')"
    curr_used="${curr_used%?}"
    [[ "$curr_used" -lt "$max_used" ]]
}

mode="$1"
case "$mode" in
    -h|--help|help)
        echo "Return overall container status"
        echo "    $0 [readiness|liveness]"
        exit 0
    ;;
    # currently the liveness and readiness check is the same
    # it does not always have to be this way
    ready|readiness|live|liveness|"")
        if [[ -z "$mode" ]] ; then
            echo "warning: no mode provided. Assuming liveness probe" >&2
        fi
        require systemctl -q is-active glusterd.service

        if [[ "$GLUSTER_BLOCK_ENABLED" -ne 0 ]] && [[ "$GLUSTER_BLOCKD_STATUS_PROBE_ENABLE" -eq 1 ]]; then
            require systemctl -q is-active gluster-blockd.service
        fi

        require filesystem_used_under_limit "/var/lib/glusterd" 99
    ;;
    *)
        echo "error: unknown mode $mode" >&2
        exit 2
    ;;
esac
