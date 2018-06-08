#!/usr/bin/env bash
# shellcheck disable=1004,1090

function spacify
{
    local string="$1"
    string="${string//:/ }"
    string="${string:1}"
    printf "%s" "${string}"
}

function get_search
{
    local search="$1"
    local -a disk_cache
    mapfile -t disk_cache <<< "${@:2}"

    local count=0
    local match="false"
    local default_disk

    if [[ "${search}" ]]; then
        while [[ "${match}" != "true" ]] && ((count < ${#disk_cache[@]})); do
            if [[ "${disk_cache[${count}]}" == *"${search}"* ]]; then
                match="true"
                search="${disk_cache[${count}]%% *}"
            else
                ((count++))
            fi
        done
    else
        default_disk="${disk_cache[1]}"
        default_disk="${default_disk%% *}"
        search="${default_disk}"
    fi

    if [[ "${match}" == "true" ]]; then
        printf "%s" "${search}"
    else
        return 1
    fi
}

function get_df_output
{
    local df_line
    local -a disk_cache

    while read -r df_line; do
        [[ "${df_line}" != *"TimeMachine"* ]] && disk_cache+=("${df_line}")
    done < <(df -P -k)
    printf "%s\\n" "${disk_cache[@]}"
}

function get_disk
{
    local -a disk_cache
    local search

    local disk_device
    local disk_capacity
    local disk_used
    local disk_percent
    local disk_name
    local disk_part
    local disk_mount

    disk_cache=("$(get_df_output "$@")")
    { ! search="$(get_search "$@" "${disk_cache[@]}")"; } && return 1

    read -r disk_device \
            disk_capacity \
            disk_used \
            disk_percent \
            < <(awk -v disk="${search}" \
                    '$0 ~ disk { 
                        a = $1
                        b = $2 / (1024 ^ 2)
                        c = $3 / (1024 ^ 2)
                        d = c / b * 100
                    }
                    END {
                        printf "%s %0.2f %0.2f %0.2f", \
                        a, b, c, d
                    }' <<< "${disk_cache[@]}")

    read -r disk_name \
            disk_part \
            disk_mount \
            < <(awk '
                    /Volume Name/ {
                        a = ""
                        for(i = 3; i <= NF; i++) {
                            a = a":"$i
                        }
                    }
                    /File System Personality:/ {
                        b = ""
                        for(i = 4; i <= NF; i++) {
                            b = b":"$i
                        }
                    }
                    /Mount Point:/ {
                        c = ""
                        for(i = 3; i <= NF; i++) {
                            c = c":"$i
                        }
                    }
                    END {
                        printf "%s %s %s", a, b, c
                    }' <(diskutil info "${search}"))

    disk_name="$(spacify "${disk_name}")"
    disk_part="$(spacify "${disk_part}")"
    disk_mount="$(spacify "${disk_mount}")"

    printf "%s;%s;%s;%s;%s;%s;%s" \
        "${disk_device}" \
        "${disk_capacity}" \
        "${disk_used}" \
        "${disk_percent}" \
        "${disk_name}" \
        "${disk_part}" \
        "${disk_mount}"
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}/}notify.sh" \
        && source "${BASH_SOURCE[0]//${0##*/}/}format.sh"; } \
            && exit 1

    IFS=";" \
    read -r disk_device \
            disk_capacity \
            disk_used \
            disk_percent \
            disk_name \
            disk_part \
            disk_mount \
            < <(get_disk "$@")

    [[ "${disk_device}" == "" \
    || "${disk_capacity}" == "0.00" \
    || "${disk_used}" == "0.00" \
    || "${disk_percent}" == "0.00" \
    ]] && exit 1

    title_parts=(
        "${disk_name:-Disk}" "(" "${disk_mount}" ")"
    )

    subtitle_parts=(
        "${disk_used}" "GiB" "|" "${disk_capacity}" "GiB"
        "(" "${disk_percent}" "%" ")"
    )

    message_parts=(
        "${disk_device}" "|" "${disk_part}"
    )

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
