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

set -ex

FAILED_PACKAGES=""

if [ "$TEST_PACKAGE" == "all" -o "$TEST_PACKAGE" == "wp-cli/wp-cli" ]; then

	# Run the functional tests for the framework.
	echo "Testing wp-cli/wp-cli framework."

	BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/wp-cli/wp-cli/features php ci/behat-tags.php)

	set +e
	vendor/bin/behat --format progress $BEHAT_TAGS --strict
	if [ $? -ne 0 ]; then
		FAILED_PACKAGES="$FAILED_PACKAGES wp-cli/wp-cli"
	fi
	set -e

fi

if [ "$TEST_PACKAGE" == "all" -o "$TEST_PACKAGE" == "commands" ]; then

	# Run the functional tests for the bundled commands.
	echo "Testing command packages."

	REPOS=$(cat vendor/wp-cli/wp-cli/composer.json | grep -oE "wp-cli/([a-z\-]*)-command")

	for REPO in $REPOS; do

		BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/$REPO/features php ci/behat-tags.php)

		set +e
		vendor/bin/behat --format progress $BEHAT_TAGS --strict -p=$REPO
		if [ $? -ne 0 ]; then
			FAILED_PACKAGES="$FAILED_PACKAGES $REPO"
		fi
		set -e

	done

fi

if [ "$TEST_PACKAGE" != "none" -o "$TEST_PACKAGE" != "all" -o "$TEST_PACKAGE" != "commands" ]; then

	# Run the functional tests for a specific package.
	echo "Testing package $TEST_PACKAGE."

	BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/$TEST_PACKAGE/features php ci/behat-tags.php)

	set +e
	vendor/bin/behat --format progress $BEHAT_TAGS --strict -p=$TEST_PACKAGE
	if [ $? -ne 0 ]; then
		FAILED_PACKAGES="$FAILED_PACKAGES $TEST_PACKAGE"
	fi
	set -e

fi

if [ -n "$FAILED_PACKAGES" ]; then
	echo "Packages with failed tests:$FAILED_PACKAGES"
	exit 1
fi

echo "All Packages were successfully tested."
exit 0
