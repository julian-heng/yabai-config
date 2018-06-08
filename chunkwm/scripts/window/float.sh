#!/usr/bin/env bash

function main
{
    # Get floating status
    i="$(chunkc tiling::query --window float)"

    # Set window to float if its not already floating
    ((i == 0)) && chunkc tiling::window --toggle float

    case "${1:0:1}" in
        "l") chunkc tiling::window --grid-layout 1:2:0:0:1:1 ;;
        "r") chunkc tiling::window --grid-layout 1:2:1:0:1:1 ;;
        "d") chunkc tiling::window --grid-layout 4:4:1:1:2:2 ;;
        "u") chunkc tiling::window --grid-layout 1:1:0:0:1:1 ;;
    esac
}

main "$@"
