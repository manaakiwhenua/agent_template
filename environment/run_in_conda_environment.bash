#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## run a python script given as an input argument in the conda
## environment

MAMBA_ROOT_PREFIX=$HOME/.micromamba

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]})/..)

## enter environment
eval "$(micromamba shell hook --shell bash)"
micromamba activate $PROJECT_ROOT/environment/conda_env

## run python
PYTHONPATH=$PROJECT_ROOT python $@


