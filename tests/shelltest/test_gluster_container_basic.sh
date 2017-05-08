#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${0}); pwd)
TESTS_DIR="${SCRIPT_DIR}/.."
INC_DIR="${TESTS_DIR}/common"
BASE_DIR="${SCRIPT_DIR}/../.."

GK_DEPLOY="${DEPLOY_DIR}/"

source "${INC_DIR}/subunit.sh"


test_syntax() {
        local file="${1}"
	bash -n ${file}
}

test_shellcheck() {
        local file="${1}"
	if ! which shellcheck ; then
		echo "ShellCheck not found: skipping..."
		return 0
	fi

	shellcheck -s bash -e SC2181 ${file}
}

failed=0

testit "test script syntax ${BASE_DIR}/CentOS/gluster-setup.sh" \
        test_syntax ${BASE_DIR}/CentOS/gluster-setup.sh \
        || ((failed++))

testit "test shellcheck ${BASE_DIR}/CentOS/gluster-setup.sh" \
        test_shellcheck ${BASE_DIR}/CentOS/gluster-setup.sh \
        || ((failed++))

testit "test script syntax ${BASE_DIR}/gluster-object/CentOS/docker-gluster-swift/update_gluster_vol.sh" \
        test_syntax ${BASE_DIR}/gluster-object/CentOS/docker-gluster-swift/update_gluster_vol.sh \
        || ((failed++))

testit "test shellcheck ${BASE_DIR}/gluster-object/CentOS/docker-gluster-swift/update_gluster_vol.sh" \
        test_shellcheck ${BASE_DIR}/gluster-object/CentOS/docker-gluster-swift/update_gluster_vol.sh \
        || ((failed++))


testok $0 ${failed}
