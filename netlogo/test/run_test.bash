#!/usr/bin/env bash
## CTRL-c to quite
trap exit int
## various safety features
set -o nounset -o errexit -o pipefail

## Get directory paths relative to this scripts
TEST_DIR=$(dirname $(readlink -f "$0"))
PROJECT_DIR="${TEST_DIR}/.."

## make output directory for tests
TEST_OUTPUT_DIR="${TEST_DIR}/output"
if [ ! -d "$TEST_OUTPUT_DIR" ] ; then
    mkdir test/output 2> /dev/null
fi


## run and analyse some tests

echo "run experiment test1"
NetLogo --headless --model "$PROJECT_DIR/ABM4CSL.nlogo" --setup-file "${TEST_DIR}/experiments/tests.xml" --experiment "test1" --table "${TEST_OUTPUT_DIR}/test1.csv"

echo
echo "Diff experiment test1 output"
echo "    > ${TEST_OUTPUT_DIR}/test1.csv"
echo "    < ${TEST_DIR}/experiments/reference_output/test1.csv"
echo
diff "${TEST_OUTPUT_DIR}/test1.csv" "${TEST_DIR}/experiments/reference_output/test1.csv"





