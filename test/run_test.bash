#!/usr/bin/env bash

PYTHON_ENVIRONMENT=$(dirname $(readlink -f $0))/../.env
. "$PYTHON_ENVIRONMENT"/bin/activate
$@

