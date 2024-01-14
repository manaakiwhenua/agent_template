#!/usr/bin/env bash

## set up environment to run tests

PYTHON_ENVIRONMENT=$(dirname $(readlink -f $0))/../.env
. "$PYTHON_ENVIRONMENT"/bin/activate
$@

