#!/usr/bin/env bash
## CTRL-c to quit
trap exit int
## various safety features
set -o nounset -o errexit -o pipefail
# set -x

## Get directory paths relative to this scripts
THIS_DIR=$(dirname $(readlink -f "$0"))
PROJECT_DIR="${THIS_DIR}/../.."

## make output directory for tests
TEST_OUTPUT_DIR="${THIS_DIR}/output"
if [ ! -d "$TEST_OUTPUT_DIR" ] ; then
    mkdir "$TEST_OUTPUT_DIR"
fi

## run and analyse some tests, either from input args, or all tests in
## EXPERIMENTS_FILE
EXPERIMENTS_FILE="${THIS_DIR}/tests.xml"
if [ $# -gt 0 ] ; then
    EXPERIMENTS_TO_RUN="$@"
else
    EXPERIMENTS_TO_RUN=$(sed -nr 's/^ *<experiment name="([^"]+)".*/\1/p' "$EXPERIMENTS_FILE")
fi

## run each test
for EXPERIMENT_NAME in $EXPERIMENTS_TO_RUN ; do

    OUTPUT_TABLE="${TEST_OUTPUT_DIR}/${EXPERIMENT_NAME}.csv"
    REFERENCE_OUTPUT_TABLE="${THIS_DIR}/reference_output/${EXPERIMENT_NAME}.csv"

    echo
    echo "run experiment ${EXPERIMENT_NAME}..."
    NetLogo --headless --model "${PROJECT_DIR}/ABM4CSL.nlogo" --setup-file "$EXPERIMENTS_FILE" --experiment "$EXPERIMENT_NAME" --table "$OUTPUT_TABLE"

    if [ -e "$OUTPUT_TABLE" ] ; then

        ## diff with reference, or make reference
        if [ -e "$REFERENCE_OUTPUT_TABLE" ] ; then
            echo "diff output / reference_output"
            echo
            # diff "${OUTPUT_TABLE}" "${REFERENCE_OUTPUT_TABLE}" || true
            git diff --no-index --word-diff=color --word-diff-regex=',' "${OUTPUT_TABLE}" "${REFERENCE_OUTPUT_TABLE}" || true
        else
            echo 'make reference output'
            cp "${OUTPUT_TABLE}" "${REFERENCE_OUTPUT_TABLE}"
        fi

        ## run analysis script
        # echo "analyse output"
        # echo
        # python "$THIS_DIR/analyse_table.py" "$OUTPUT_TABLE"

    fi
    
done




