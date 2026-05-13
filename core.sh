#!/bin/bash
set -e

HELP_TEXT=${HELP_TEXT:-"This is a management script."}

_setup_actions() {
    ACTIONS=()
    HELP_SECTIONS=()
    ADDITIONAL_HELP=()

    help() {
        INDENT=$(printf '%*s' "$1")
        if [[ -z $INDENT ]]
        then
            echo "$INDENT$HELP_TEXT"
        fi
        local AC='\e[0;32m'
        local NC='\e[0m'
        for action_index in "${!ACTIONS[@]}"
        do
            echo -e "$INDENT - ${AC}${ACTIONS[$action_index]}${NC}: ${HELP_SECTIONS[$action_index]}"
            ADDITIONAL_HELP_CMD="${ADDITIONAL_HELP[$action_index]}"
            if [[ -n $ADDITIONAL_HELP_CMD ]]
            then
                $ADDITIONAL_HELP_CMD
            fi
        done
    }

    _add_action() {
        ACTIONS+=("$1")
        HELP_SECTIONS+=("$2")
        ADDITIONAL_HELP+=("$3")
    }

    _run() {
        local action="$1"
        local TC='\e[0;31m'
        local NC='\e[0m'
        if [ -n "$action" ] && grep -qF -w -e "$action" <<<"${ACTIONS[*]}"
        then
            _info "${TC}# Running: $action${NC}"
            "$action" "${@:2:99}"
        else
            echo -e "${TC}# Manage script${NC}"
            help
        fi
    }

    _require_distro() {
        local DISTRONAME=`cat /etc/*-release | grep -Po '^NAME="\K[^"]*'`
        if [ ! "$DISTRONAME" = "$1" ]; then
            echo "Warning: Incorrect distro name \"$DISTRONAME\". Expected \"$1\"";
            exit 1;
        fi
    }

    _assert_equal() {
        VAL_A=$1
        VAL_B=$2
        MESSAGE=$3
        if [[ "$VAL_A" != "$VAL_B" ]]; then
            echo "${MESSAGE}";
            exit 1;
        fi
    }

    _assert_gt() {
        VAL_A=$1
        VAL_B=$2
        MESSAGE=$3
        if [[ "$VAL_A" -gt "$VAL_B" ]]; then
            echo "${MESSAGE}";
            exit 1;
        fi
    }

    _info() {
        USE_VERBOSE="${VERBOSE:-0}"
        if [ "$USE_VERBOSE" = "1" ]; then echo -e "$1"; fi
    }

    _add_action "help" "Display help message and a list of available commands"
}

_setup_actions
