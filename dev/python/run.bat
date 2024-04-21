@echo off

set PYTHON_ENVIRONMENT=".env"

@REM create python environment if necessary
IF NOT EXIST %PYTHON_ENVIRONMENT% (
    python -m venv %PYTHON_ENVIRONMENT%
    %PYTHON_ENVIRONMENT%\Scripts\activate.bat
    pip install --requirement=requirements.txt  --editable .
    deactivate
)

@REM run agent_template if any command line arguments are given
IF NOT "%~1"=="" (
    %PYTHON_ENVIRONMENT%\Scripts\activate.bat
    python -m agent_template %*
    deactivate
)



