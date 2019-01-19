#!/usr/bin/env bash

check_apps()
{
    if ! type -p vm_stat sysctl osascript 2>&1 > /dev/null; then
        return 1
    fi
}

notify()
{
    title="${title_parts[*]}"
    subtitle="${subtitle_parts[*]}"
    message="${message_parts[*]}"

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

get_mem_info()
{
    awk_script='
        /hw/ { total = $2 / (1024 ^ 2) }
        / wired/ { a = substr($4, 1, length($4) - 1) }
        / active/ { b = substr($3, 1, length($3) - 1) }
        / occupied/ { c = substr($5, 1, length($5) - 1) }
        /vm/ { d = $7; e = $4 }
        END {
            used = ((a + b + c) * 4) / 1024
            printf "%f %f %f %s %s", \
                ((used / total) * 100), used, total, d, e
        }'

    read -r mem_percent \
            mem_used \
            mem_total \
            swap_used \
            swap_total \
            < <(awk "${awk_script}" < <(vm_stat; sysctl vm.swapusage hw.memsize))

    printf -v mem_percent "%.*f" "0" "${mem_percent}"
    printf -v mem_used "%.*f" "0" "${mem_used}"
    printf -v mem_total "%.*f" "0" "${mem_total}"

    swap_used="${swap_used/M}"
    swap_used="${swap_used%%.00}"

    swap_total="${swap_total/M}"
    swap_total="${swap_total%%.00}"
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
    get_mem_info

    [[ "${raw}" ]] && {
        printf -v out "%s," \
            "${mem_percent}%" \
            "${mem_used} MiB" \
            "${mem_total} MiB" \
            "${swap_used} MiB"
        printf -v out "%s%s" "${out}" "${swap_total}"
        printf "%s\\n" "${out}"
        exit 0
    }

    [[ "${mem_percent}" ]] && \
        title_parts+=("Memory" "(${mem_percent}%)")

    [[ "${mem_used}" ]] && \
        subtitle_parts+=("${mem_used}" "MiB")

    [[ "${mem_total}" ]] && \
        subtitle_parts+=("|" "${mem_total}" "MiB")

    [[ "${swap_used}" ]] && \
        message_parts+=("Swap:" "${swap_used}" "MiB")

    [[ "${swap_total}" ]] && \
        message_parts+=("|" "${swap_total}" "MiB")

    notify
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && \
    main "$@"
