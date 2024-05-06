@echo off
if /I "%1%" == "cdk-synth" (goto cdk-synth)
goto list

:cdk-synth
set ACCOUNT_NAME=curated

for %%I in (.) do set GITHUB_REPO_NAME=%%~nxI

npm install aws-cdk -g & cd infrastructure & python -m venv .venv & source & python -m pip install -r requirements.txt & cdk synth & deactivate & cd ..

goto end

:list
echo cdk-synth
:end