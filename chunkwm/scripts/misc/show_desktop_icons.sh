#!/usr/bin/env bash

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}}../display/notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}../display/format.sh"; } && \
            exit 1

    title_parts=("Finder")
    subtitle_parts=()

    : "$(defaults read com.apple.finder CreateDesktop)"
    if ((${_} == 1)); then
        message_parts=("Hiding desktop icons")
        : "false"
    else
        message_parts=("Showing desktop icons")
        : "true"
    fi
    defaults write com.apple.finder CreateDesktop -bool "${_}"

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
    killall Finder
}

main
