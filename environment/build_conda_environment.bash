#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]})/..)

## install all dependencies into a conda environment in directory env
## using micromamba
micromamba create \
           --prefix="$PROJECT_ROOT"/environment/conda_env \
           --file="$PROJECT_ROOT"/environment/conda_env.yaml \
           --yes \
           --quiet
