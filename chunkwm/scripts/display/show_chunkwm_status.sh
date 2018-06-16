#!/usr/bin/env bash
# shellcheck disable=1090

function check_gaps
{
    read -r gaps_top \
            gaps_bottom \
            gaps_left \
            gaps_right \
            gaps_inner \
            < <(awk -F'=' '
                    /_top/ { a=$2 }
                    /_bottom/ { b=$2 }
                    /_left/ { c=$2 }
                    /_right/ { d=$2 }
                    /_inner/ { print a, b, c, d, $2 }' \
                    "${HOME}/.chunkwmrc")

    ((${gaps_top//\"} > 0 || \
      ${gaps_bottom//\"} > 0 || \
      ${gaps_left//\"} > 0 || \
      ${gaps_right//\"} > 0 || \
      ${gaps_inner//\"} > 0)) \
        && return 1

    return 0
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}}notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}format.sh"; } && \
            exit 1

    if check_gaps; then
        : "No gaps"
    else
        : "gaps"
    fi
    gaps="${_}"

    title_parts=(
        "$(chunkwm --version)"
    )

    subtitle_parts=(
        "Mode:" "$(chunkc tiling::query --desktop mode)" "|"
        "${gaps}"
    )

    message_parts=(
        "Desktop:" "$(chunkc tiling::query --desktop id)"
    )

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
    main "$@" || :
