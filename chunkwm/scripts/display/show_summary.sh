#!/usr/bin/env bash
# shellcheck disable=1090,2034,2154

function convert_mem
{
    : "$(awk -v a="$1" 'BEGIN {printf "%0.2f", a / 1024}')"
    printf "%s" "${_}"
}

function get_args
{
    while (($# > 0)); do
        case "$1" in
            "-d"|"--disk")  disk="$2"; shift ;;
            "simple"|"all") mode="$1" ;;
        esac
        shift
    done
}

function main
{
    script_dir="${BASH_SOURCE[0]//${0##*/}}"

    ! { source "${script_dir}show_bat.sh" && \
        source "${script_dir}show_cpu.sh" && \
        source "${script_dir}show_disk.sh" && \
        source "${script_dir}show_mem.sh" && \
        source "${script_dir}notify.sh" && \
        source "${script_dir}format.sh"; } && \
            exit 1

    get_args "$@"

    printf -v current_time "%(%H:%M)T" "-1"
    printf -v current_date "%(%a %d %h)T" "-1"

    case "${mode}" in
        "")
            title_parts=("${current_date}" "|" "${current_time}")
            subtitle_parts=()
            message_parts=()
        ;;
        "simple")
            ! disk_search="$(get_search "${disk:-}")" && return 1
            mapfile -t disk_out < <(get_diskutil_out "${disk_search}")

            cpu_usage="$(get_cpu_usage)"
            mem_percent="$(get_mem_percent)"
            disk_used="$(get_disk_used "${disk_out[@]}")"
            disk_capacity="$(get_disk_capacity "${disk_out[@]}")"
            disk_percent="$(get_disk_percent "${disk_used}" "${disk_capacity}")"
            bat_percent="$(get_bat_percent "$(get_bat_cache)")"

            title_parts=(
                "${current_date}" "|" "${current_time}"
            )

            subtitle_parts=(
                "CPU:" "${cpu_usage}" "%" "|"
                "Mem:" "${mem_percent}" "%"
            )

            message_parts=(
                "Disk:" "${disk_percent}" "%" "|"
                "Battery:" "${bat_percent}"
            )
        ;;
        "all")
            ! disk_search="$(get_search "${disk:-}")" && return 1
            mapfile -t disk_out < <(get_diskutil_out "${disk_search}")

            cpu_usage="$(get_cpu_usage)"
            temp="$(get_temp)"

            : "$(get_mem_used "$(get_mem_cache)")"
            : "$(convert_mem "${_}")"
            mem_used="$(trim_digits "${_}")"

            : "$(get_mem_total)"
            : "$(convert_mem "${_}")"
            mem_total="$(trim_digits "${_}")"

            mem_percent="$(get_mem_percent "${mem_used}" "${mem_total}")"
            bat_percent="$(get_bat_percent "$(get_bat_cache)")"
            disk_used="$(get_disk_used "${disk_out[@]}")"
            disk_capacity="$(get_disk_capacity "${disk_out[@]}")"
            disk_percent="$(get_disk_percent "${disk_used}" "${disk_capacity}")"

            title_parts=(
                "${current_date}" "|" "${current_time}"
            )

            subtitle_parts=(
                "CPU:" "${cpu_usage}" "%"
                "(" "${temp}" ")" "|"
                "Mem:" "${mem_used}" "GiB" "/" "${mem_total}" "GiB"
            )

            message_parts=(
                "Bat:" "${bat_percent}" "|"
                "Disk:" "${disk_used}" "GiB" "/" "${disk_capacity}" "GiB"
                "(" "${disk_percent}" "%" ")"
            )
        ;;
    esac

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
    main "$@"
