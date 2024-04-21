#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]})/..)

## build docker image
docker build -t agent_template -f "$PROJECT_ROOT"/environment/Dockerfile .
