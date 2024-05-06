SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: help

help:  ##List the targets
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

create-infrastructure-venv:
	test -d infrastructure/.venv || cd infrastructure && python -m venv .venv
	chmod 755 infrastructure/.venv/bin/activate
	( \
		source infrastructure/.venv/bin/activate; \
		python3 -m pip install -r infrastructure/requirements.txt -r requirements-validation.txt; \
	)

create-e2e-tests-venv:
	test -d 2e2/.venv || cd e2e && python -m venv .venv
	chmod 755 e2e/.venv/bin/activate
	( \
		source e2e/.venv/bin/activate; \
		python3 -m pip install -r e2e/requirements.txt; \
	)

run-software-validations:
	echo "Run software validations..."
	docker-compose run docker-aws-scripts ./do/validate.sh

run-software-tests:
	echo "Run unit tests..."
	docker-compose up --build --exit-code-from docker-aws-scripts

run-software-coverage:
	echo "Run software coverage..."
	docker-compose run docker-aws-scripts ./do/coverage.sh

run-infrastructure-validations: create-infrastructure-venv
	chmod 755 infrastructure/.venv/bin/activate
	( \
		source infrastructure/.venv/bin/activate; \
		export PYTHONPATH=$PYTHONPATH:./infrastructure/; \
		\
		echo "Run pycodestyle ..."; \
		\
		echo "Run pylint ..."; \
		pylint infrastructure/app.py infrastructure/lib/; \
	)

run-infrastructure-tests: create-infrastructure-venv
	chmod 755 infrastructure/.venv/bin/activate
	( \
		source infrastructure/.venv/bin/activate; \
		export PYTHONPATH=./infrastructure/; \
		\
		echo "Run pytest on infrastructure..."; \
		pytest --cov-report= --cov=infrastructure/lib/stacks/ infrastructure/lib/stages/ infrastructure/tests/; \
	)

run-infrastructure-coverage:
	chmod 755 infrastructure/.venv/bin/activate
	( \
		source infrastructure/.venv/bin/activate; \
		export PYTHONPATH=./infrastructure/; \
		\
		echo "Run coverage on infrastructure..."; \
		./do/coverage.sh; \
	)

cdk-synth: create-infrastructure-venv
	npm install aws-cdk -g
	chmod 755 infrastructure/.venv/bin/activate
	( \
		source infrastructure/.venv/bin/activate; \
		cd infrastructure && cdk bootstrap && cdk synth; \
	)

cdk-deploy: create-infrastructure-venv
	chmod 755 infrastructure/.venv/bin/activate
	( \
		source infrastructure/.venv/bin/activate; \
		cd infrastructure && cdk deploy --app 'cdk.out/' $(arg1)/* --require-approval never; \
	)

run-e2e-tests: create-e2e-tests-venv
	chmod 755 e2e/.venv/bin/activate
	( \
		source e2e/.venv/bin/activate; \
		export PYTHONPATH=$PYTHONPATH:./e2e; \
		\
		echo "Run E2E..."; \
		pytest e2e/tests/e2e.py; \
	)
