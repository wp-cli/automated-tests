#!/bin/bash

# The tests to be run are selected based on the $TEST_PACKAGE and $TEST_PHAR
# environment variables.
#
# $TEST_PACKAGE enables tests against source packages. You can select which
# commands/packages to test.
#
# The following options can be set:
#
# - "none": No packages are tested.
# - "all": The framework as well as all bundled commands are tested.
# - "commands": Only the command packages are tested.
# - <package name>: Only the package named <package name> is tested.
#
# $TEST_PHAR enables tests against the Phar distributions. You can select which
# distribution to test. The selected distribution will be tested against all
# bundled commands/packages.
#
# The following options can be set:
#
# - "none": Skip phar testing.
# - "nightly": Use the nightly phar.
# - "stable": Use the latest stable phar release.
# - "all": Use both the latest stable release phar as well as the nightly phar.

set -e

BUILD_DIR=$(pwd)

if [ ${TRAVIS_BUILD_DIR+x} ]; then
	BUILD_DIR="$TRAVIS_BUILD_DIR"
fi

if [ $WP_VERSION = "latest" ]; then
	export WP_VERSION=$(curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r ".offers[0].current")
fi

if [ ${TEST_PHAR+x} ]; then
	echo "Running Phar distribution tests..."
	$BUILD_DIR/ci/test-phar.sh
	exit 0
fi

if [ ${TEST_PACKAGE+x} ]; then
	echo "Running source package tests..."
	$BUILD_DIR/ci/test-package.sh
fi
