#!/usr/bin/env bash

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}}../display/notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}../display/format.sh"; } && \
            exit 1

    title_parts=("chunkwm")
    subtitle_parts=()
    message_parts=("Restarting chunkwm")

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
    brew services restart chunkwm
}

main
