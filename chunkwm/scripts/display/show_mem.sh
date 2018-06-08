#!/usr/bin/env bash
# shellcheck disable=1004,1090

function trim_digits
{
    case "${1##*.}" in
        "00")   printf "%s" "${1/.*}" ;;
        *)      printf "%s" "$1" ;;
    esac
}

function get_mem_info
{
    local mem_wired
    local mem_compressed
    local mem_total
    local mem_used
    local mem_percent
    local swap_total
    local swap_used

    read -r mem_wired \
            mem_compressed \
            swap_total \
            swap_used \
            < <(awk '
                    /wired/ { a=$4 }
                    /occupied/ { b=$5 }
                    /vm/ { c=$4; d=$7 }
                    END {
                        printf "%s %s %s %s", \
                        a, b, c, d
                    }' <(vm_stat; sysctl vm.swapusage))

    mem_total="$(($(sysctl -n hw.memsize) / 1024 ** 2))"
    mem_used="$(((${mem_wired//.} + ${mem_compressed//.}) * 4 / 1024))"
    mem_percent="$(awk \
                    -v a="${mem_total}" \
                    -v b="${mem_used}" \
                        'BEGIN {
                            percent = b / a * 100
                            printf "%0.0f", percent
                        }'
                    )"

    swap_total="$(trim_digits "${swap_total/M*}")"
    swap_used="$(trim_digits "${swap_used/M*}")"

    printf "%s;%s;%s;%s;%s" \
        "${mem_percent}" \
        "${mem_used}" \
        "${mem_total}" \
        "${swap_used}" \
        "${swap_total}"
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}/}notify.sh" \
        && source "${BASH_SOURCE[0]//${0##*/}/}format.sh"; } \
            && exit 1

    IFS=";"\
    read -r mem_percent \
            mem_used \
            mem_total \
            swap_used \
            swap_total \
            < <(get_mem_info)

    title_parts=(
        "Memory" "(" "${mem_percent}" "%" ")"
    )

    subtitle_parts=(
        "${mem_used}" "MiB" "|" "${mem_total}" "MiB"
    )

    message_parts=(
        "Swap:" "${swap_used}" "MiB" "|" "${swap_total}" "MiB"
    )

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
