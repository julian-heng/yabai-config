#!/usr/bin/env bash
# shellcheck disable=1004,1090

function trim_digits
{
    case "${1##*.}" in
        "00")   printf "%s" "${1/.*}" ;;
        *)      printf "%s" "$1" ;;
    esac
}

function get_mem_cache
{
    vm_stat; sysctl vm.swapusage
}

function get_mem_total
{
    : $(($(sysctl -n hw.memsize) / 1024 ** 2))
    printf "%s" "${_}"
}

function get_mem_used
{
    : "$(awk '
        /wired/ {a = substr($4, 1, length($4)-1)}
        /occupied/ {b = substr($5, 1, length($5)-1)}
        END {printf "%0.0f", ((a + b) * 4) / 1024}' \
        < <(printf "%s\\n" "$@"))"
    printf "%s" "${_}"
}

function get_mem_percent
{
    local used
    local total

    if [[ ! "$1" && ! "$2" ]]; then
        used="$(get_mem_used "$(get_mem_cache)")"
        total="$(get_mem_total)"
    else
        used="$1"
        total="$2"
    fi

    : "$(awk -v a="${used}" -v b="${total}" \
        'BEGIN {printf "%0.0f", (a / b) * 100}')"
    printf "%s" "${_}"
}

function get_swap_used
{
    : "$(awk \
        '/vm/ { print $4 }' < <(printf "%s\\n" "$@"))"
    : "$(trim_digits "${_/M*}")"
    printf "%s" "${_}"
}

function get_swap_total
{
    : "$(awk \
        '/vm/ { print $7 }' < <(printf "%s\\n" "$@"))"
    : "$(trim_digits "${_/M*}")"
    printf "%s" "${_}"
}

function get_mem_info
{
    local mem_total
    local mem_used
    local mem_percent
    local swap_total
    local swap_used

    read -r mem_used \
            swap_total \
            swap_used \
            < <(awk '
                    /wired/ {a = substr($4, 1, length($4)-1)}
                    /occupied/ {b = substr($5, 1, length($5)-1)}
                    /vm/ {c = $4; d = $7}
                    END {
                        printf "%0.0f %s %s", \
                        ((a + b) * 4) / 1024, c, d
                    }' < <(get_mem_cache))

    mem_total="$(($(sysctl -n hw.memsize) / 1024 ** 2))"
    mem_percent="$(get_mem_percent "${mem_used}" "${mem_total}")"
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
    ! { source "${BASH_SOURCE[0]//${0##*/}}notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}format.sh"; } && \
            exit 1

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

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
    main "$@" || :
