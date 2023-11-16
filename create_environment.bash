#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## install all dependencies into a conda environment in directory env
## using micromamba
micromamba create --prefix=./env --file=env.yaml --yes --quiet
