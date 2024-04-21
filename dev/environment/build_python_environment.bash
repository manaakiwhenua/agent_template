#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]})/..)

## delete existing environment
if [[ -d "$PROJECT_ROOT"/environment/python_env ]] ; then
    rm -rf "$PROJECT_ROOT"/environment/python_env
fi

## start a new one
python -m venv "$PROJECT_ROOT"/environment/python_env

## enter environment
. "$PROJECT_ROOT"/environment/python_env/bin/activate

## install dependencies
pip install -r python_requirements.txt























