#!/usr/bin/env bash

function main
{
    # Get floating status
    : "$(chunkc tiling::query --window float)"

    # Set window to float if its not already floating
    ((${_} == 0)) && chunkc tiling::window --toggle float

    case "${1:0:1}" in
        "l") : "1:2:0:0:1:1" ;;
        "r") : "1:2:1:0:1:1" ;;
        "d") : "4:4:1:1:2:2" ;;
        "u") : "1:1:0:0:1:1" ;;
    esac
    chunkc tiling::window --grid-layout "${_}"
}

main "$@"
