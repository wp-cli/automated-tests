WP-CLI Automated Tests
======================

This repository runs automated tests for the nightly Phar builds of WP-CLI.

[![Testing](https://github.com/wp-cli/automated-tests/actions/workflows/testing.yml/badge.svg)](https://github.com/wp-cli/automated-tests/actions/workflows/testing.yml)

## Usage Instructions

The testing is set up through the use of environment variables in the Travis CI matrix configuration.

### Testing source packages

`$TEST_PACKAGE` enables tests against source packages. You can select which commands/packages to test.

The following options can be set:

* **`none`** - No packages are tested.
* **`all`** - The framework as well as all bundled commands are tested.
* **`commands`** - Only the command packages are tested.
* **`<package name>`** - Only the package named <package name> is tested.

### Testing against Phar distributions

`$TEST_PHAR` enables tests against the Phar distributions. You can select which distribution to test. The selected distribution will be tested against all bundled commands/packages.

The following options can be set:

* **`none`** - Skip phar testing.
* **`nightly`** - Use the nightly phar.
* **`stable `** - Use the latest stable phar release.
* **`all`** - Use both the latest stable release phar as well as the nightly phar.

### JUnit reports

`$WP_CLI_TEST_JUNIT_DIR` writes JUnit reports to the given directory, in addition to the progress output that is always printed. This is useful to compare the results of two runs, as the reports name every scenario along with the file and line it is defined on, which the progress output does not.

```bash
WP_CLI_TEST_JUNIT_DIR=build/junit TEST_PACKAGE=wp-cli/entity-command composer test
```

Behat names each report after the suite it belongs to, so one package results in one report:

```
build/junit/wp_cli_entity_command.xml
build/junit/rerun/wp_cli_entity_command.xml
```

Failed scenarios are run a second time. Reports of that rerun are written to the `rerun` subdirectory, as they only cover the scenarios that failed the first time and would otherwise overwrite the full report of the package. A scenario that is reported as failed in the first report but does not appear in the rerun report passed on the second attempt, and was therefore flaky rather than failing.

### Automated Builds

This repository is being rebuilt through a Travis CI cron job every 24 hours to post test results in Emails and Slack.
