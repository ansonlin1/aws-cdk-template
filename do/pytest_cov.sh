#!/bin/bash -e

if [ $# -eq 0 ]; then
  test_dir=/work/software/tests
else
  test_dir=$1
fi

if [[ $test_dir != "/work/"* ]]; then
  test_dir=$(pwd)/$test_dir
fi

coverage_dir=${test_dir/tests/src}

echo Running: pytest --cov-report= --cov=$coverage_dir $test_dir
pytest --cov-report= --cov=$coverage_dir $test_dir
coverage report