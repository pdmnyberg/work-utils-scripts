#!/bin/bash

export HELP_TEXT="This scripts contains \
utility functions that work for presentations:"

_setup_presentation_actions() {
    source "${SCRIPTS}/core.sh"

    DOCKER="${DOCKER:-docker}"
    DOCUMENT_BUILDER_NAME="document-builder"
    PRESENTATIONS_PATH="${PRESENTATIONS_PATH:-./presentations}"
    DIAGRAMS_PATH="${DIAGRAMS_PATH:-./presentations}"
    PRESENTATIONS_SRC="${PRESENTATIONS_SRC:-src}"
    PRESENTATIONS_COMMON_STYLE="${PRESENTATIONS_COMMON_STYLE:-$PRESENTATIONS_SRC/common_style.tex}"

    _run_container() {
        ${DOCKER} build --tag "${DOCUMENT_BUILDER_NAME}" -f "${SCRIPTS}/containers/document-builder.Dockerfile" "${SCRIPTS}"
		${DOCKER} run \
			-it \
			--rm \
			--user "$(id -u):$(id -g)" \
            -e SRC="$PRESENTATIONS_SRC" \
            -e COMMON_STYLE="$PRESENTATIONS_COMMON_STYLE" \
			-v ./:/opt/output \
			"$@"
	}

    build() {
        _run_container \
            -v "${PRESENTATIONS_PATH}:/opt/build/presentations" \
            -v "./makefiles/presentations.Makefile:/opt/build/Makefile" \
            --workdir=/opt/build/presentations \
            "${DOCUMENT_BUILDER_NAME}" make -f ../Makefile "$@"
    }

    build-diagrams() {
        _run_container \
            -v "${DIAGRAMS_PATH}:/opt/build/diagrams" \
            -v "./makefiles/diagrams.Makefile:/opt/build/Makefile" \
            --workdir=/opt/build/diagrams \
            "${DOCUMENT_BUILDER_NAME}" make -f ../Makefile "$@"
    }

    _add_action "build" "Build all presentations"
    _add_action "build-diagrams" "Build diagrams using graphviz"
}

presentations_cmd() {
    _setup_presentation_actions
    _run $@
}