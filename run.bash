#!/usr/bin/env bash

## Conveniently run agent_template in a python virutal environment.
## If the environment is not present it is first generated from
## `requirements.txt`.

## input arguments
DEBUG="false"
while getopts :d OPT; do
    case $OPT in
        d|+d)
            DEBUG="true"
            ;;
        *)
            echo "usage: ${0##*/} [+-d} [--] ARGS..."
            echo ""
            echo "   -d to run the Python debugger"
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1

## get an absolute path to python environment relative to this script
AGENT_TEMPLATE_PYTHON_ENVIRONMENT=$(dirname $(readlink -f $0))/.env

## install dependencies in directory local directory .env, along with
## agent_template in editable mode
if [[ ! -d .env ]] ; then
   python -m venv "$AGENT_TEMPLATE_PYTHON_ENVIRONMENT"
   . .env/bin/activate
   pip install --requirement=requirements.txt  --editable .
   deactivate
fi

## run agent_template with arguments 
. "$AGENT_TEMPLATE_PYTHON_ENVIRONMENT"/bin/activate

## run model, optionally in the debugger
if [[ "$DEBUG" = "false" ]] ; then
    python -m agent_template $@
else
    python -m pdb -m agent_template $@
fi

