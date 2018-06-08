#!/usr/bin/env bash

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}/}../display/notify.sh" \
        && source "${BASH_SOURCE[0]//${0##*/}/}../display/format.sh"; } \
            && exit 1

    check="$(defaults read com.apple.finder CreateDesktop)"
    title_parts=("Finder")
    subtitle_parts=()

    if ((check == 1)); then
        message_parts=("Hiding desktop icons")
        defaults write com.apple.finder CreateDesktop -bool false
    else
        message_parts=("Showing desktop icons")
        defaults write com.apple.finder CreateDesktop -bool true
    fi

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"

    killall Finder
}

main
