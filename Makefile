SHELL := bash
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := default
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: default
default: test lint lint_github_action

.PHONY: test
test:
	if [ -n "$$(find test -type f -name 'vim-*.vader')" ]; then
	 	vim -E -s -N -U NONE -u test/vader.vimrc -c 'Vader! test/**/vim-*.vader'
	fi
	if [ -n "$$(find test -type f -name '*.vim')" ]; then
		THEMIS_VIM=vim themis --recursive --reporter tap
	fi

.PHONY: test-nvim
test-nvim:
	if [ -n "$$(find test -type f -name 'nvim-*.vader')" ]; then
	 	nvim -E -s -U NONE -u test/vader.vimrc -c 'Vader! test/**/nvim-*.vader'
	fi
	if [ -n "$$(find test -type f -name '*.vim')" ]; then
		THEMIS_VIM=nvim themis --recursive --reporter tap
	fi

.PHONY: lint
lint:
	if ! hash vint; then
		echo 'vint not found, exit.' >&2; exit 1
	fi
	vint .

.PHONY: lint_github_actions
lint_github_action:
	actionlint -verbose -color

.PHONY: all
all: test test-nvim lint lint_github_actions
