#!/bin/bash

# The phar package to be tested against can be set through the TEST_PHAR
# environment variable.
#
# The following options can be set:
#
# - "none": Skip phar testing.
# - "nightly": Use the nightly phar.
# - "stable": Use the latest stable phar release.
# - "all": Use both the latest stable release phar as well as the nightly phar.

set -ex

FAILED_PACKAGES=""

RELEASES=""
REPOS="wp-cli/wp-cli
$(cat vendor/wp-cli/wp-cli/composer.json | grep -oE "wp-cli/([a-z\-]*)-command")"

if [ -z "$TEST_PHAR" -o "$TEST_PHAR" == "none" ]; then
	echo "Skipping feature tests completely."
	exit 0
fi

if [ "$TEST_PHAR" == "all" ]; then
	RELEASES="nightly
stable"
fi

if [ "$TEST_PHAR" != "all" ]; then
	RELEASES="$TEST_PHAR"
fi

for RELEASE in $RELEASES; do

	echo "Testing $RELEASE Phar distribution..."

	SUFFIX=""
	if [ "$RELEASE" == "nightly" ]; then
		SUFFIX="-nightly"
	fi

	PHAR_URL="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli${SUFFIX}.phar"
	MD5_URL="${PHAR_URL}.md5"

	# Download binary and verify MD5 checksum.
	BIN_FOLDER="$(mktemp -d)"
	wget -O "${BIN_FOLDER}/wp-cli.phar.md5" "$MD5_URL"
	TARGET_MD5=$(cat "${BIN_FOLDER}/wp-cli.phar.md5")
	wget -O "${BIN_FOLDER}/wp-cli.phar" "$PHAR_URL"
	if hash md5sum 2>/dev/null; then
		DOWNLOAD_MD5=$(md5sum "${BIN_FOLDER}/wp-cli.phar" | cut -d ' ' -f 1)
	else
		DOWNLOAD_MD5=$(md5 -q "${BIN_FOLDER}/wp-cli.phar")
	fi
	if [ ! "$TARGET_MD5" == "$DOWNLOAD_MD5" ]; then
		echo MD5 mismatch, the download for the ${RELEASE} distribution seems to be corrupt.
		exit 1
	fi

	export WP_CLI_BIN_DIR="${BIN_FOLDER}"
	mv "${WP_CLI_BIN_DIR}/wp-cli.phar" "${WP_CLI_BIN_DIR}/wp"
	chmod +x "${BIN_FOLDER}/wp"

	for REPO in $REPOS; do

		BEHAT_TAGS=$(BEHAT_FEATURES_FOLDER=vendor/$REPO/features php ci/behat-tags.php)

		set +e
		vendor/bin/behat --format progress $BEHAT_TAGS --strict $BEHAT_PROFILE
		if [ $? -ne 0 ]; then
			FAILED_PACKAGES="$FAILED_PACKAGES ${RELEASE}:${REPO}"
		fi
		set -e

	done

done

if [ -n "$FAILED_PACKAGES" ]; then
	echo "Phar distributions and packages with failed tests:$FAILED_PACKAGES"
	exit 1
fi

echo "Phar distributions were successfully tested."
exit 0
