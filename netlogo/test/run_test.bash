#!/usr/bin/env bash
## CTRL-c to quite
trap exit int
## various safety features
set -o nounset -o errexit -o pipefail

## root at netlogo/
PROJECT_DIR=$(dirname $(readlink -f "$0"))/..
cd $PROJECT_DIR

## make output directory for tests
TEST_OUTPUT_DIR=test/output
if [ ! -d "$TEST_OUTPUT_DIR" ] ; then
    mkdir test/output 2> /dev/null
fi

## run tests

NetLogo --headless --model ABM4CSL.nlogo --setup-file test/experiments.xml --experiment test1 --table "${TEST_OUTPUT_DIR}/test1.csv"

