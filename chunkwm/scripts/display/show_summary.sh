#!/usr/bin/env bash
# shellcheck disable=1090,2034,2154

function convert_mem
{
    local convert
    convert="$(awk -v a="$1" 'BEGIN { b = a / 1024; printf "%0.2f", b }')"
    printf "%s" "${convert}"
}

function get_everything
{
    local everything
    everything="$(get_cpu_usage)"
    everything+=";$(get_temp)"
    everything+=";$(get_bat_info)"
    everything+=";$(get_mem_info)"
    everything+=";$(get_disk "$@")"
    printf "%s" "${everything}"
}

function get_args
{
    while [[ "$1" ]]; do
        case "$1" in
            "-d"|"--disk")  disk="$2"; shift ;;
            "simple"|"all") mode="$1" ;;
        esac
        shift
    done
    [[ ! ${mode} ]] && mode=""
}

function main
{
    script_dir="${BASH_SOURCE[0]//${0##*/}/}"

    ! { source "${script_dir}show_bat.sh" \
        && source "${script_dir}show_cpu.sh" \
        && source "${script_dir}show_disk.sh" \
        && source "${script_dir}show_mem.sh" \
        && source "${script_dir}notify.sh" \
        && source "${script_dir}format.sh"; } \
            && exit 1

    get_args "$@"

    printf -v current_time "%(%H:%M)T" -1
    printf -v current_date "%(%a %d %h)T" -1

    case "${mode}" in
        "")
            title_parts=("${current_date}" "|" "${current_time}")
            subtitle_parts=()
            message_parts=()
        ;;
        *)
            IFS=";" \
            read -r cpu_usage \
                    temp \
                    bat_state \
                    bat_percent \
                    bat_time \
                    bat_cycles \
                    bat_condition \
                    mem_percent \
                    mem_used \
                    mem_total \
                    swap_used \
                    swap_total \
                    disk_device \
                    disk_capacity \
                    disk_used \
                    disk_percent \
                    disk_name \
                    disk_part \
                    disk_mount \
                    < <(get_everything "${disk:-disk1s1}")

                mem_used="$(trim_digits "$(convert_mem "${mem_used}")")"
                mem_total="$(trim_digits "$(convert_mem "${mem_total}")")"

                disk_used="$(trim_digits "${disk_used}")"
                disk_capacity="$(trim_digits "${disk_capacity}")"

            case "$1" in
                "all")
                    title_parts=(
                        "${current_date}" "|" "${current_time}"
                    )

                    subtitle_parts=(
                        "CPU:" "${cpu_usage}"
                        "(" "${temp}" ")" "|"
                        "Mem:" "${mem_used}" "GiB" "/" "${mem_total}" "GiB"
                    )

                    message_parts=(
                        "Bat:" "${bat_percent}" "|"
                        "Disk:" "${disk_used}" "GiB" "/" "${disk_capacity}" "GiB"
                        "(" "${disk_percent}" "%" ")"
                    )
                ;;
                "simple")
                    title_parts=(
                        "${current_date}" "|" "${current_time}"
                    )

                    subtitle_parts=(
                        "CPU:" "${cpu_usage}" "|"
                        "Mem:" "${mem_percent}" "%" "|"
                        "Disk:" "${disk_percent}" "%"
                    )

                    message_parts=(
                        "Battery:" "${bat_percent}"
                    )
                ;;
            esac
        ;;
    esac
    shift

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
