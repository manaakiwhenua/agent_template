#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## get the directory of this project
PROJECT_ROOT=$(realpath $(dirname -- ${BASH_SOURCE[0]}))

## run a python script in the conda environment
sudo PYTHONPATH=$PROJECT_ROOT micromamba run --prefix=$PROJECT_ROOT/env python $@


