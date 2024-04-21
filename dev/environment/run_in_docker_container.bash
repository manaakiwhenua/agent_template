#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]})/..)

## run python in container
docker run -v "$PROJECT_ROOT":/work agent_template $@

























