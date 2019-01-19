#!/usr/bin/env bash

check_apps()
{
    if ! type -p sysctl osascript 2>&1 > /dev/null; then
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

get_cpu()
{
    cpu="${cpu_info[0]/@/(${cpu_info[1]}) @}"
    cpu="${cpu/(R)}"
    cpu="${cpu/(TM)}"
    cpu="${cpu/ CPU}"
}

get_load()
{
    read -r _ a b c _ <<< "${cpu_info[2]}"
    load_avg="$a $b $c"
}

get_cpu_usage()
{
    awk_script='
        { sum += $3 }
        END {
            printf "%f", sum / cores
        }'
    cpu_usage="$(awk -v cores="${cpu_info[1]:-1}" \
                     -v sum="0" \
                     "${awk_script}" <(ps aux))"
    printf -v cpu_usage "%.*f" "1" "${cpu_usage}"
}

get_fan_temp()
{
    type -p osx-cpu-temp 2>&1 > /dev/null && {
        while read -r line; do
            case "${line}" in
                "CPU"*)         temp="${line#*:}" ;;
                "Fan "[0-9]*)   fan="${line/'Fan '}" ;;
            esac
        done < <(osx-cpu-temp -f -c)

        printf -v temp "%.*f" "1" "${temp/'°C'}"
        fan="${fan/*at }"
        fan="${fan/ RPM*}"
    }
}

get_uptime()
{
    boot="${cpu_info[3]/'{ sec = '}"
    boot="${boot/,*}"
    seconds="$(($(printf "%(%s)T" "-1") - boot))"

    days="$((seconds / 60 / 60 / 24))d "
    hours="$((seconds / 60 / 60 % 24))h "
    mins="$((seconds / 60 % 60))m "
    secs="$(((seconds % 60) % 60))s"

    ((${days/d*} == 0)) && unset days
    ((${hours/h*} == 0)) && unset hours
    ((${mins/m*} == 0)) && unset mins
    ((${secs/s} == 0)) && unset secs

    uptime="${days}${hours}${mins}${secs}"
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

    sysctl_args=(
        "machdep.cpu.brand_string"
        "hw.logicalcpu_max"
        "vm.loadavg"
        "kern.boottime"
    )

    mapfile -t cpu_info < <(sysctl -n ${sysctl_args[@]})
    get_cpu
    get_load
    get_cpu_usage
    get_fan_temp
    get_uptime

    [[ "${raw}" ]] && {
        printf -v out "%s," \
            "${cpu}" \
            "${load_avg}" \
            "${cpu_usage}%" \
            "${temp}°C" \
            "${fan} RPM"
        printf -v out "%s%s" "${out}" "${uptime}"
        out="$(trim "${out}")"
        printf "%s\\n" "${out}"
        exit 0
    }

    title_parts+=("${cpu:-CPU}")

    [[ "${load_avg}" ]] && \
        subtitle_parts+=("Load avg:" "${load_avg}")

    [[ "${cpu_usage}" ]] && \
        subtitle_parts+=("|" "${cpu_usage}%")

    [[ "${temp}" ]] && \
        subtitle_parts+=("|" "${temp}°C")

    [[ "${fan}" ]] && \
        subtitle_parts+=("|" "${fan} RPM")

    [[ "${uptime}" ]] && \
        message_parts+=("Uptime:" "${uptime}")

    notify
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && \
    main "$@"
