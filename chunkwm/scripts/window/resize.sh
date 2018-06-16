#!/usr/bin/env bash

function resize
{
    while [[ "$1" ]]; do
        chunkc tiling::window --use-temporary-ratio "$1" --adjust-window-edge "$2"
        shift; shift
    done
}

function main
{
    case "${1:0:1}" in
        "l") resize "0.05" "west" "-0.05" "east" ;;
        "r") resize "0.05" "east" "-0.05" "west" ;;
        "d") resize "0.05" "south" "-0.05" "north" ;;
        "u") resize "0.05" "north" "-0.05" "south" ;;
    esac
}

main "$@"
