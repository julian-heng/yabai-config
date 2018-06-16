#!/usr/bin/env bash
# shellcheck disable=1090,2194

function strip
{
    case "$2" in
        "0")    unset "$1" ;;
        *)      printf "%s" "$2${1:0:1} " ;;
    esac
}

function trim_digits
{
    case "${1##*.}" in
        "00")   printf "%s" "${1/.*}" ;;
        *)      printf "%s" "$1" ;;
    esac
}

function get_cpu
{
    : "$(sysctl -n machdep.cpu.brand_string)"
    : "${_/@/(${cores}) @}"
    : "${_/(R)}"
    : "${_/(TM)}"
    printf "%s" "${_}"
}

function get_load
{
    : "$(sysctl -n vm.loadavg)"
    : "${_/"{ "}"
    : "${_/" }"}"
    printf "%s" "${_}"
}

function get_cpu_usage
{
    : "$(awk -v cores="${cores:-1}" \
             -v sum="0" '
                {sum += $3}
                END {
                    printf "%0.0f", sum / cores
                }' <(ps aux))"
    : "$(trim_digits "${_}")"
    printf "%s" "${_}"
}

function get_temp
{
    : "$(osx-cpu-temp)"
    printf "%s" "${_}"
}

function get_fan_speed
{
    : "$(awk 'NR==2 {print}' <(istats fan --value-only))"
    : "${_:-0}"
    : "${_// } RPM"
    printf "%s" "${_}"
}

function get_uptime
{
    local boot
    local now
    local seconds
    local days
    local hours
    local mins
    local secs

    : "$(sysctl -n kern.boottime)"
    : "${_/"{ sec = "}"
    boot="${_/,*}"
    printf -v now "%(%s)T" "-1"
    seconds="$((now - boot))"

    : "$((seconds / 60 / 60 / 24))"
    days="$(strip "days" "${_}")"

    : "$((seconds / 60 / 60 % 24))"
    hours="$(strip "hours" "${_}")"

    : "$((seconds / 60 % 60))"
    mins="$(strip "mins" "${_}")"

    : "$((seconds % 60 % 60 % 24))"
    secs="$(strip "seconds" "${_}")"

    : "${days:-}${hours:-}${mins:-}${secs// }"
    printf "%s" "${_}"
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}}notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}format.sh"; } && \
            exit 1

    cores="$(sysctl -n hw.logicalcpu_max)"

    cpu="$(get_cpu)"
    load="$(get_load)"
    cpu_usage="$(get_cpu_usage)"
    temp="$(get_temp)"
    fan="$(get_fan_speed)"
    uptime="$(get_uptime)"

    title_parts=(
        "${cpu}"
    )

    subtitle_parts=(
        "Load avg:" "${load}" "|"
        "${cpu_usage}" "%" "|"
        "${temp}" "|"
        "${fan}"
    )

    message_parts=(
        "Uptime:" "${uptime}"
    )

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    case "1" in
        "$((${#subtitle} >= 50))")    subtitle="${subtitle/" avg"}" ;&
        "$((${#subtitle} >= 50))")    subtitle="${subtitle/"Load: "}" ;;
    esac

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
    main "$@" || :
