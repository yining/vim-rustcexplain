SHELL := bash
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := default
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: default
default: test lint

# TODO: integration with github action
.PHONY: test
test:
	if ls test/*.vader; then
		./test/run_vader.sh
	fi
	if ! hash themis; then
		echo 'themis not found, exit.' >&2; exit 1
	fi
	if ls test/*.vim; then
		themis --recursive --reporter tap
	fi

.PHONY: lint
lint:
	if ! hash vint; then
		echo 'vint not found, exit.' >&2; exit 1
	fi
	vint .
