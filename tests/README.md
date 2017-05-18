# Testsuite

This directory contains tests for gluster-containers.
These are tests that do not test the full stack end-to-end
but are syntax-checks or unit-tests.

## Prerequisites

The Dockerfile lint tests require the 'dockerfile_lint' program.
Install it with

* `dnf install npm`, or
* `apt-get install npm`

* `npm install dockerfile_lint`

Ref: https://github.com/projectatomic/dockerfile_lint

The test uses ShellCheck.
Install with

* `dnf install ShellCheck`, or
* `apt-get install shellcheck`

## Travis CI
* dockerfile_lint has dependency problem, hence disabling it.
* Builds the docker image and does a basic test.
* Tests the shell script.

## TODOs

* Write more tests
* Write full functional tests to be run in vms.
 (like the atomic vagrant environment)

