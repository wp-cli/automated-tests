#!/bin/bash

set -x

# Run the functional tests for the framework
BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/wp-cli/wp-cli/features php ci/behat-tags.php)
vendor/bin/behat --format progress $BEHAT_TAGS --strict

# Run the functional tests for the bundled commands
REPOS=$(cat vendor/wp-cli/wp-cli/composer.json | grep -oE "wp-cli/([a-z\-]*)-command")
for REPO in $REPOS; do
	BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/$REPO/features php ci/behat-tags.php)
	vendor/bin/behat --format progress $BEHAT_TAGS --strict -p=$REPO
done
