#!/bin/bash

export HELP_TEXT="This scripts contains \
utility functions that start and manage ollama:"

_setup_ollama_actions() {
    source "${SCRIPTS}/core.sh"

    DOCKER="${DOCKER:-docker}"
    CONTAINER_NAME="ollama"
    CONTAINER_VOLUME="ollama"
    USE_GPU="${USE_GPU:-NO}"

    start() {
        if [ "$USE_GPU" = "AMD" ]; then
            ${DOCKER} run --rm -d \
                --device /dev/kfd \
                --device /dev/dri \
                -v ${CONTAINER_VOLUME}:/root/.ollama \
                -p 11434:11434 \
                --name ${CONTAINER_NAME} \
                ollama/ollama:rocm
        elif [ "$USE_GPU" = "NVIDIA" ]; then
            ${DOCKER} run --rm -d \
                --gpus=all \
                -v ${CONTAINER_VOLUME}:/root/.ollama \
                -p 11434:11434 \
                --name ${CONTAINER_NAME} \
                ollama/ollama
        else
            ${DOCKER} run --rm -d \
                -v ${CONTAINER_VOLUME}:/root/.ollama \
                -p 11434:11434 \
                --name ${CONTAINER_NAME} \
                ollama/ollama
        fi
    }

    stop() {
        ${DOCKER} stop ${CONTAINER_NAME}
    }

    cmd() {
        ${DOCKER} exec -it ${CONTAINER_NAME} ollama "$@"
    }

    run() {
        cmd run "$@"
    }

    _add_action "start" "Start the ollama container"
    _add_action "stop" "Stop and remove the ollama container"
    _add_action "cmd" "Run a ollama command"
    _add_action "run" "Run a model in ollama"
}

ollama_cmd() {
    _setup_ollama_actions
    _run $@
}