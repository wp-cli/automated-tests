#!/bin/bash

# The tests to be run are selected based on the $TEST_PACKAGE environment
# variable.
#
# The following options can be set:
#
# - "none": No packages are tested.
# - "all": The framework as well as all bundled commands are tested.
# - "commands": Only the command packages are tested.
# - <package name>: Only the package named <package name> is tested.

if [ ${TEST_PACKAGE+x} ]; then
	"Running source package tests..."
	ci/test-package.sh
fi

if [ ${TEST_PHAR+x} ]; then
	"Running Phar distribution tests..."
	ci/test-phar.sh
fi
