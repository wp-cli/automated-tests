#!/bin/bash

set -ex

FAILED_PACKAGES=""

# Run the functional tests for the framework.
BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/wp-cli/wp-cli/features php ci/behat-tags.php)

set +e
vendor/bin/behat --format progress $BEHAT_TAGS --strict
if [ $? -ne 0 ]; then
	FAILED_PACKAGES="$FAILED_PACKAGES wp-cli/wp-cli"
fi
set -e

# Run the functional tests for the bundled commands
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

if [ $FAILED_PACKAGES -ne "" ]; then
	echo "Packages with failed tests:$FAILED_PACKAGES"
	exit 1
fi

echo "All Packages were successfully tested."
exit 0
