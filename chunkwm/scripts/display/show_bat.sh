#!/usr/bin/env bash
# shellcheck disable=1004,1090

function get_bat_info
{
    local bat_state
    local bat_percent
    local bat_time
    local bat_cycles
    local bat_condition

    read -r bat_state \
            bat_percent \
            bat_time \
            bat_cycles \
            bat_condition \
            < <(awk '
                    /drawing/ { a=$4 }
                    /id=/ { b=$3; c=$5 }
                    /Cycle Count/ { d=$3 }
                    /Condition/ { e=$2 }
                    END { 
                        printf "%s %s %s %s %s", \
                        a, b, c, d, e 
                    }' <(pmset -g batt; system_profiler SPPowerDataType))

    bat_percent="${bat_percent//;/}"
    bat_state="${bat_state//\'/}"

    if [[ "${bat_time}" =~ ^(\(no|charge;)$ ]]; then
        bat_time="Unknown"
    elif [[ "${bat_time}" == "0:00"* && "${bat_state}" == "AC" ]]; then
        bat_time="Fully Charged"
    else
        bat_time+=" remaining"
    fi

    printf "%s;%s;%s;%s;%s" \
        "${bat_state}" \
        "${bat_percent}" \
        "${bat_time}" \
        "${bat_cycles}" \
        "${bat_condition}"
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}/}notify.sh" \
        && source "${BASH_SOURCE[0]//${0##*/}/}format.sh"; } \
            && exit 1

    IFS=";" \
    read -r bat_state \
            bat_percent \
            bat_time \
            bat_cycles \
            bat_condition \
            < <(get_bat_info)

    title_parts=(
        "Battery" "(" "${bat_percent}" ")"
    )

    subtitle_parts=(
        "${bat_time}" "|" "${bat_condition}" "|" "${bat_cycles}" "cycles"
    )

    message_parts=(
        "Source:" "${bat_state}"
    )

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
