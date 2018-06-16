#!/usr/bin/env bash

function get_current_values
{
    local gaps_top
    local gaps_bottom
    local gaps_left
    local gaps_right
    local gaps_inner

    read -r gaps_top \
            gaps_bottom \
            gaps_left \
            gaps_right \
            gaps_inner \
            < <(awk -F'=' '
                    /_top/ {a = $2}
                    /_bottom/ {b = $2}
                    /_left/ {c = $2}
                    /_right/ {d = $2}
                    /_inner/ {print a, b, c, d, $2}' \
                    "${chunkwmrc}")

    printf "%s %s %s %s %s" \
        "${gaps_top//\"}" \
        "${gaps_bottom//\"}" \
        "${gaps_left//\"}" \
        "${gaps_right//\"}" \
        "${gaps_inner//\"}"
}

function set_defaults
{
    local default_gaps_top
    local default_gaps_bottom
    local default_gaps_left
    local default_gaps_right
    local default_gaps_inner

    read -r default_gaps_top \
            default_gaps_bottom \
            default_gaps_left \
            default_gaps_right \
            default_gaps_inner \
            < <(awk -F'=' '
                    /_top/ {a = $2}
                    /_bottom/ {b = $2}
                    /_left/ {c = $2}
                    /_right/ {d = $2}
                    /_inner/ {print a, b, c, d, $2}' \
                    "${chunkwmrc}.orig")

    printf "%s %s %s %s %s" \
        "${default_gaps_top//\"}" \
        "${default_gaps_bottom//\"}" \
        "${default_gaps_left//\"}" \
        "${default_gaps_right//\"}" \
        "${default_gaps_inner//\"}"
}

function restore_defaults
{
    local gaps_top
    local gaps_bottom
    local gaps_left
    local gaps_right
    local gaps_inner

    read -r gaps_top \
            gaps_bottom \
            gaps_left \
            gaps_right \
            gaps_inner \
            < <(set_defaults)

    change_file "${gaps_top}" \
                "${gaps_bottom}" \
                "${gaps_left}" \
                "${gaps_right}" \
                "${gaps_inner}" \
                "${chunkwmrc}.orig" \
                "${chunkwmrc}"

    message_parts=("Restoring config to default")

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"

    brew services restart chunkwm
    exit 0
}

function get_gap_state
{
    ((current_gaps_top > 0 || \
      current_gaps_bottom > 0 || \
      current_gaps_left > 0 || \
      current_gaps_right > 0 || \
      current_gaps_inner > 0 )) \
        && return 1

    return 0
}

function change_file
{
    awk -v top="gaps_top=\"${1}\"" \
        -v bottom="gaps_bottom=\"${2}\"" \
        -v left="gaps_left=\"${3}\"" \
        -v right="gaps_right=\"${4}\"" \
        -v inner="gaps_inner=\"${5}\"" \
            '/_top=/ {$1 = top}
            /_bottom=/ {$1 = bottom}
            /_left=/ { $1 = left}
            /_right=/ {$1 = right}
            /_inner=/ {$1 = inner}; {print}' \
            "${6}" > "${7}"
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}}../display/notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}../display/format.sh"; } && \
            exit 1

    [[ ! "$1" ]] && {
        printf "%s\\n" "Needs to have arguments"
        exit 1
    }

    chunkwmrc="${HOME}/.chunkwmrc"
    title_parts=("chunkwm")

    [[ ! -f "$chunkwmrc.orig" ]] && \
        cp "${chunkwmrc}" "${chunkwmrc}.orig"
    cp "${chunkwmrc}" "${chunkwmrc}.tmp"

    read -r current_gaps_top \
            current_gaps_bottom \
            current_gaps_left \
            current_gaps_right \
            current_gaps_inner \
            < <(get_current_values)

    case "$1" in
        "-d"|"--defaults") restore_defaults ;;
        "-s"|"--skip")
            shift
            message_parts=("Changing gaps")
            case "$1" in
                "!!") gaps_top="${current_gaps_top}" ;;
                *)    gaps_top="$1" ;;
            esac
            case "$2" in
                "!!") gaps_bottom="${current_gaps_bottom}" ;;
                *)    gaps_bottom="$2" ;;
            esac
            case "$3" in
                "!!") gaps_left="${current_gaps_left}" ;;
                *)    gaps_left="$3" ;;
            esac
            case "$4" in
                "!!") gaps_right="${current_gaps_right}" ;;
                *)    gaps_right="$4" ;;
            esac
            case "$5" in
                "!!") gaps_inner="${current_gaps_inner}" ;;
                *)    gaps_inner="$5" ;;
            esac
        ;;

        *)
            if get_gap_state; then
                message_parts=("Enabling gaps")
                gaps_top="$1"
                gaps_bottom="$2"
                gaps_left="$3"
                gaps_right="$4"
                gaps_inner="$5"
            else
                message_parts=("Disabling gaps")
                gaps_top="0"
                gaps_bottom="0"
                gaps_left="0"
                gaps_right="0"
                gaps_inner="0"
            fi
        ;;
    esac

    change_file "${gaps_top}" \
                "${gaps_bottom}" \
                "${gaps_left}" \
                "${gaps_right}" \
                "${gaps_inner}" \
                "${chunkwmrc}.tmp" \
                "${chunkwmrc}"

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
    brew services restart chunkwm
    rm "${chunkwmrc}.tmp"
}

main "$@"
