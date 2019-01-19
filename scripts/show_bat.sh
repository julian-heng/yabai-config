#!/usr/bin/env bash

check_apps()
{
    if ! type -p pmset system_profiler 2>&1 > /dev/null; then
        return 1
    fi
}

trim()
{
    [[ "$*" ]] && {
        set -f
        set -- $*
        printf "%s" "$*"
        set +f
    }
}

notify()
{
    title="$(trim "${title_parts[*]}")"
    subtitle="$(trim "${subtitle_parts[*]}")"
    message="$(trim "${message_parts[*]}")"

    [[ "${title:0:1}" == "|" ]] && \
        title="${title##'| '}"

    [[ "${title:-1:1}" == "|" ]] && \
        title="${title%%' |'}"

    [[ "${subtitle:0:1}" == "|" ]] && \
        subtitle="${subtitle##'| '}"

    [[ "${subtitle:-1:1}" == "|" ]] && \
        subtitle="${subtitle%%' |'}"

    [[ "${message:0:1}" == "|" ]] && \
        message="${message##'| '}"

    [[ "${message:-1:1}" == "|" ]] && \
        message="${message%%' |'}"

    if [[ "${stdout}" ]]; then
        [[ "${title}" ]] && \
            display+=("${title}")
        [[ "${subtitle}" ]] && \
            display+=("${subtitle}")
        [[ "${message}" ]] && \
            display+=("${message}")
        printf "%s\\n" "${display[@]}"
    else
        osa_script="display notification \"${message}\" \
                    with title \"${title}\" \
                    subtitle \"${subtitle}\""

        /usr/bin/env osascript <<< "${osa_script}"
    fi
}

get_bat_info()
{
    awk_script='
        /drawing/ { a = $4 }
        /id=/ { b = $3; c = $5 }
        /Cycle Count/ { d = $3 }
        /Condition/ { e = $2 }
        END {
            printf "%s %s %s %s %s", \
                a, b, c, d, e
        }'

    read -r bat_state \
            bat_percent \
            bat_time \
            bat_cycles \
            bat_condition \
            < <(awk "${awk_script}" <(pmset -g batt; system_profiler SPPowerDataType))

    bat_percent="${bat_percent//;}"
    bat_state="${bat_state//\'}"

    if [[ "${bat_time}" =~ ^(\(no|charge;)$ ]]; then
        bat_time="Unknown"
    elif [[ "${bat_time}" == "0:00"* && "${bat_state}" == "AC" ]]; then
        bat_time="Fully Charged"
    fi
}

print_usage()
{
    printf "%s\\n" "
Usage: ${0##*/} --option

    Options:

    [--stdout]      Print to stdout
    [-r|--raw]      Print raw values delimited by commas
    [-h|--help]     Show this message
"
}

get_args()
{
    while (($# > 0)); do
        case "$1" in
            "--stdout")     stdout="true" ;;
            "-r"|"--raw")   raw="true" ;;
            "-h"|"--help")  print_usage; exit ;;
        esac
        shift
    done
}

main()
{
    ! check_apps && exit 1
    get_args "$@"
    get_bat_info

    [[ "${raw}" ]] && {
        printf -v out "%s," \
            "${bat_percent}" \
            "${bat_time}" \
            "${bat_condition}" \
            "${bat_cycles}"
        printf -v out "%s%s" "${out}" "${bat_state}"
        printf "%s\\n" "${out}"
        exit 0
    }

    title_parts+=("Battery")

    [[ "${bat_percent}" ]] && \
        title_parts+=("(${bat_percent})")

    [[ "${bat_time}" ]] && \
        subtitle_parts+=("|" "${bat_time} remaining")

    [[ "${bat_condition}" ]] && \
        subtitle_parts+=("|" "${bat_condition}")

    [[ "${bat_cycles}" ]] && \
        subtitle_parts+=("|" "${bat_cycles} cycles")

    [[ "${bat_state}" ]] && \
        message_parts+=("Souce: ${bat_state}")

    notify
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && \
    main "$@"
