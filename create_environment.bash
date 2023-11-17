#!/usr/bin/env bash
trap exit int
set -o nounset -o errexit

## install all dependencies into a conda environment in directory env
## using micromamba
micromamba create --prefix=environment/env --file=environment/env.yaml --yes --quiet
