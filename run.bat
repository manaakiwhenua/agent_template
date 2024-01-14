@echo off

set PYTHON_ENVIRONMENT=".env"

@REM create python environment if necessary
IF NOT EXIST %PYTHON_ENVIRONMENT% (
    python -m venv %PYTHON_ENVIRONMENT%
    %PYTHON_ENVIRONMENT%\Scripts\activate.bat
    pip install --requirement=requirements.txt  --editable .
    deactivate
)


@REM run agent_template with arguments 
@REM Need the parenthese to get venv to activate/deactivate correctly?
(
    %PYTHON_ENVIRONMENT%\Scripts\activate.bat
    python -m agent_template %*
    deactivate
)



