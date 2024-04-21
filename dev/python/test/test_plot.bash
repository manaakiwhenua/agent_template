#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

TEST_DIRECTORY=$(dirname $(readlink -f $0))
PYTHON_ENVIRONMENT="${TEST_DIRECTORY}"/../.env
TEST_OUTPUT_DIRECTORY="$TEST_DIRECTORY"/output


. "$PYTHON_ENVIRONMENT"/bin/activate

## delete existing output directory
[[ -e "$TEST_OUTPUT_DIRECTORY" ]] && trash-put "$TEST_OUTPUT_DIRECTORY"

## test various plotting types
python -m agent_template "$TEST_DIRECTORY"/test_config.yaml verbose=False plot=pdf
python -m agent_template "$TEST_DIRECTORY"/test_config.yaml verbose=False plot=png
python -m agent_template "$TEST_DIRECTORY"/test_config.yaml verbose=False plot=window
python -m agent_template "$TEST_DIRECTORY"/test_config.yaml verbose=False plot=solara

