#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]})/..)


## enter environment
. "$PROJECT_ROOT"/environment/python_env/bin/activate

export PYTHONPATH=$PROJECT_ROOT

## run python
$@


