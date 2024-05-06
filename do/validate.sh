#!/bin/bash -e

export PYTHONPATH=./software/src:./software/tests

echo "Run pycodestyle ..."
pycodestyle --config=.pycodestyle -r software/src/ -r software/tests/

echo "Run pylint ..."
pylint software/src/ software/tests/
