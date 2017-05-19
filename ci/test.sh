#!/bin/bash

set -ex

BEHAT_TAGS=$(php ci/behat-tags.php)

# Run the functional tests for the framework
vendor/bin/behat --format progress $BEHAT_TAGS --strict

# Run the functional tests for the bundled commands
REPOS=$(cat composer.json | grep -m 1 -oE "wp-cli/([a-z\-]*)-command")
for REPO in $REPOS; do
	vendor/bin/behat --format progress $BEHAT_TAGS --strict -p=$REPO
done
