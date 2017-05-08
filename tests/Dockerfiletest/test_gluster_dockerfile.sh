#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${0}); pwd)
TESTS_DIR="${SCRIPT_DIR}/.."
INC_DIR="${TESTS_DIR}/common"
BASE_DIR="${SCRIPT_DIR}/../.."
FAULTY_DOCKERFILE="${SCRIPT_DIR}/Dockerfile_faulty"

source "${INC_DIR}/subunit.sh"

check_dockerfilelint_invalid() {
        local file="${1}"
        check_dockerfilelint ${file}
       	if [[ "x$?" == "x0" ]]; then
		echo "ERROR: parsing invalid Dockerfile succeeded"
		return 1
	fi

	return 0
}

check_dockerfilelint() {
        local file="${1}"
        if ! which dockerfile_lint ; then
                echo "dockerfile_lint not found: skipping..."
                return 0
        fi

        dockerfile_lint -p -f ${file}
}

failed=0

	testit "check invalid Dockerfile" \
		check_dockerfilelint_invalid ${FAULTY_DOCKERFILE} \
		|| ((failed++))

	for Dockerfile in $(find ${BASE_DIR} -name "Dockerfile") ; do
		testit "check Dockerfile_lint $(basename ${Dockerfile})" \
			check_dockerfilelint ${Dockerfile} \
			|| ((failed++))
	done


testok $0 ${failed}
