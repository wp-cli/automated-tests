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

set -e

FAILED_PACKAGES=""

REPOS=""

if [ -z "$TEST_PACKAGE" -o "$TEST_PACKAGE" == "none" ]; then
	echo "Skipping feature tests completely."
	exit 0
fi

if [ "$TEST_PACKAGE" == "all" ]; then
	REPOS="wp-cli/wp-cli-bundle
wp-cli-/wp-cli
$(cat vendor/wp-cli/wp-cli-bundle/composer.json | grep -oE "wp-cli/([a-z\-]*)-command")"
fi

if [ "$TEST_PACKAGE" == "commands" ]; then
	REPOS="$(cat vendor/wp-cli/wp-cli-bundle/composer.json | grep -oE "wp-cli/([a-z\-]*)-command")"
fi

if [ "$TEST_PACKAGE" != "all" -a "$TEST_PACKAGE" != "commands" ]; then
	REPOS="$TEST_PACKAGE"
fi

for REPO in $REPOS; do

	echo "Testing package $REPO..."

	BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/${REPO}/features php vendor/wp-cli/wp-cli-tests/utils/behat-tags.php)
	echo "Behat Tags: $BEHAT_TAGS"

	BEHAT_PROFILE=""
	if [ "$REPO" != "wp-cli/wp-cli" ]; then
		BEHAT_PROFILE=" --profile $REPO"
	fi

	set +e
	vendor/bin/behat --format progress $BEHAT_TAGS --strict $BEHAT_PROFILE
	if [ $? -ne 0 ]; then
		FAILED_PACKAGES="$FAILED_PACKAGES $REPO"
	fi
	set -e

done

if [ -n "$FAILED_PACKAGES" ]; then
	echo "Packages with failed tests:$FAILED_PACKAGES"
	exit 1
fi

echo "All Packages were successfully tested."
exit 0
