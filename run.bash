#!/usr/bin/env bash


DEBUG="false"
while getopts :d OPT; do
    case $OPT in
        d|+d)
            DEBUG="true"
            ;;
        *)
            echo "usage: ${0##*/} [+-d} [--] ARGS..."
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1

## get an absolute path to python environment
PYTHON_ENVIRONMENT=$(dirname $(readlink -f $0))/.env
echo $PYTHON_ENVIRONMENT

## install dependencies in directory local directory .env, along with
## agent_template in editable mode
if [[ ! -d .env ]] ; then
   python -m venv "$PYTHON_ENVIRONMENT"
   . .env/bin/activate
   pip install --requirement=requirements.txt  --editable .
   deactivate
fi

## run agent_template with arguments 
. "$PYTHON_ENVIRONMENT"/bin/activate

if [[ "$DEBUG" = "false" ]] ; then
    python -m agent_template $@
else
    python -m pdb -m agent_template $@
fi

