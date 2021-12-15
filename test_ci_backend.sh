#!/usr/bin/env bash

set -e

# run black - make sure everyone uses same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run isort for import structure checkup with black profile
isort --atomic --profile black -c src
isort --atomic --profile black -c tests

# run mypy
cd src
mypy .
cd ..

# run bandit - A security linter from OpenStack Security
bandit -r src

# python static analysis
prospector --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

# run semgrep
semgrep --strict --error --config .semgrep_rules.yml src

# python tests
py.test -c pytest_ci.ini -x --disable-socket -W error::RuntimeWarning --cov=src --cov-fail-under=$MINIMUM_COVERAGE
