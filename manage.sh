#!/bin/bash

export HELP_TEXT="This script contains a number of \
utility functions that aims to simplify the process of development. \
The available actions are as follows:"

_setup_manage() {
	SCRIPTS="${SCRIPTS:-.}"
	source "${SCRIPTS}/core.sh"

	DOCKER="${DOCKER:-docker}"
	USE_WORKDIR="${WORKDIR:-.}"

	NODE_CONTAINER=${NODE_CONTAINER:-node:24}
	PYTHON_CONTAINER=${PYTHON_CONTAINER:-python:3.13-slim}
	ATLAS_CONTAINER=${ATLAS_CONTAINER:-arigaio/atlas}
	SWAGGER_CONTAINER=${SWAGGER_CONTAINER:-swaggerapi/swagger-codegen-cli:v2.4.51}
	GO_CONTAINER=${GO_CONTAINER:-golang:1.22}

	_require_workdir() {
		if [ ! -d "${USE_WORKDIR}" ]; then
			echo -e "${TC}Error${NC}: The working directory does not exist: ${USE_WORKDIR}";
			exit;
		fi
	}

	_run_with_workdir() {
		_require_workdir
		${DOCKER} run \
			-it \
			--rm \
			--user "$(id -u):$(id -g)" \
			-v ./:/opt/output \
			--workdir "/opt/output/${USE_WORKDIR}" \
			"$@"
	}

	node() {
		_run_with_workdir ${NODE_CONTAINER} node "$@"
	}

	node-shell() {
		_run_with_workdir --entrypoint bash ${NODE_CONTAINER}
	}

	npm() {
		_run_with_workdir ${NODE_CONTAINER} npm "$@"
	}

	npx() {
		_run_with_workdir ${NODE_CONTAINER} npx "$@"
	}

	go() {
		_run_with_workdir \
			-e GOCACHE="/opt/output/.go-cache" \
			${GO_CONTAINER} go "$@"
	}

	python() {
		_run_with_workdir ${PYTHON_CONTAINER} python "$@"
	}

	python-shell() {
		_run_with_workdir ${PYTHON_CONTAINER} bash "$@"
	}

	atlas() {
		_run_with_workdir ${ATLAS_CONTAINER} "$@"
	}

	swagger-cli() {
		_run_with_workdir ${SWAGGER_CONTAINER} "$@"
	}

	vm() {
		source "$SCRIPTS/vms.sh"
		vms "$@"
	}

	ollama() {
		source "$SCRIPTS/ollama.sh"
		ollama_cmd "$@"
	}

	wip() {
		mkdir -p "wip/$1"
		WORKDIR="wip/$1" ./manage "${@:2:99}"
	}

	presentations() {
		source "$SCRIPTS/presentations.sh"
		presentations_cmd "$@"
	}

	_add_action "node" "Runs command using node"
	_add_action "node-shell" "Starts a node shell"
	_add_action "atlas" "Runs atlas database migrationt tool"
	_add_action "npm" "Runs command using npm"
	_add_action "npx" "Runs command using npx"
	_add_action "go" "Runs command using go"
	_add_action "python" "Runs command using python"
	_add_action "ollama" "Runs an ollama command" "./manage ollama help 2"
	_add_action "python-shell" "Run using shell in python container"
	_add_action "swagger-cli" "Run using swagger cli container"
	_add_action "vm" "Runs a VM utility command" "./manage vm help 2"
	_add_action "wip" "Run any action in WIP workdir. Ex. wip <subdir> <cmd> [...args]"
	_add_action "presentations" "Run presentations utility command"  "./manage presentations help 2"
}

manage() {
	_setup_manage
	_run $@
}
