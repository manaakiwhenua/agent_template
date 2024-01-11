#!/usr/bin/env bash


## install dependencies in directory local directory .env, along with
## agent_template in editable mode
if [[ ! -d .env ]] ; then
   python -m venv .env
   .env/bin/pip install --requirement=requirements.txt  --editable .
fi

## run agent_template with arguments 
. .env/bin/activate
python -m agent_template $@
