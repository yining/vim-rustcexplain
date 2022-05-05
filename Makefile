SHELL := bash
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := default
.DELETE_ON_ERROR:
.SUFFIXES:

COVERAGE_DATA_FILE=.coverage
COVERAGE_HTML_DIR=htmlcov

.PHONY: default
default: test lint lint_github_action

.PHONY: clean
clean:
	rm -f profile-*.txt
	rm -f .coverage_covimerage*
	rm -f .coverage
	rm -rf htmlcov/*

.PHONY: test
test:
	if [ -n "$$(find test -type f -name 'vim-*.vader')" ]; then
	 	VADER_PROFILE='profile-vader-vim.txt' \
			vim -E -s -N -u test/vader.vimrc -c 'Vader! test/**/vim-*.vader'
	fi
	if [ -n "$$(find test -type f -name '*.vim')" ]; then
		THEMIS_VIM=vim THEMIS_PROFILE='profile-themis-vim.txt' \
		   themis --recursive --reporter tap
	fi

.PHONY: test-nvim
test-nvim:
	if [ -n "$$(find test -type f -name 'nvim-*.vader')" ]; then
	 	VADER_PROFILE='profile-vader-nvim.txt' \
			nvim -E -s -N -u test/vader.vimrc -c 'Vader! test/**/nvim-*.vader'
	fi
	if [ -n "$$(find test -type f -name '*.vim')" ]; then
		THEMIS_VIM=nvim THEMIS_PROFILE='profile-themis-nvim.txt' \
		   themis --recursive --reporter tap
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

.PHONY: coverage-gen
coverage-gen:
	for profile_file in profile-*.txt; do
		echo $$profile_file
		poetry run covimerage write_coverage --append $$profile_file
	done
	poetry run coverage report -m | tee .coverage

.PHONY: coverage-html
coverage-html:
	poetry run coverage html -d $(COVERAGE_HTML_DIR)

.PHONY: all
all: clean test test-nvim lint lint_github_actions coverage-gen coverage-html
