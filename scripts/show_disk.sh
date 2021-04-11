#!/usr/bin/env bash

check_apps()
{
    if ! type -p df diskutil 2>&1 > /dev/null; then
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

get_search()
{
    match="false"

    [[ "$*" ]] && {
        [[ "$1" ]] && \
            search="$1"

        [[ "$2" ]] && \
            type="$2"
    }

    if [[ "${search}" ]]; then
        while [[ "${match}" != "true" ]] && read -r df_line; do
            case "${type:-disk}" in
                "disk")
                    [[ "${df_line}" =~ ${search} ]] && {
                        match="true"
                        dev_match="${df_line%% *}"
                    }
                ;;

                "mount")
                    [[ "${df_line}" =~ ${search}$ ]] && {
                        match="true"
                        dev_match="${df_line%% *}"
                    }
                ;;
            esac
        done < <(printf "%s\\n" "${df_out[@]}")
    else
        match="true"
        get_root
    fi

    if [[ ! "${dev_match}" ]]; then
        return 1
    fi
}

get_root()
{
    get_search "/" "mount"
}

get_disk_info()
{
    awk_script='
        function strloop(a)
        {
            j = ""
            for (i = a; i <= NF; i++)
            {
                if (j == "")
                    j = $i
                else
                    j = j":"$i
            }
            return j
        }

        /Device Node/ { a = $3 }
        /Volume Name/ { b = strloop(3) }
        /File System Personality:/ { c = strloop(4) }
        /Mount Point/ { d = strloop(3) }
        /Container Total Space/ { e = $9 / (2 * (1024 ^ 2)) }
        /Container Free Space/ { f = $9 / (2 * (1024 ^ 2)) }
        END {
            printf "%s %s %s %s %f %f %f", \
                a, b, c, d, \
                e, e - f, (((e - f) / e) * 100)
        }'

    read -r disk_device \
            disk_name \
            disk_part \
            disk_mount \
            disk_capacity \
            disk_used \
            disk_percent \
            < <(awk "${awk_script}" < <(diskutil info "${dev_match}"))

    disk_name="${disk_name//:/ }"
    disk_part="${disk_part//:/ }"
    disk_mount="${disk_mount//:/ }"

    printf -v disk_capacity "%.*f" "2" "${disk_capacity}"
    printf -v disk_used "%.*f" "2" "${disk_used}"
    printf -v disk_percent "%.*f" "2" "${disk_percent}"
}

print_usage()
{
    printf "%s\\n" "
Usage: ${0##*/} --option

    Options:

    [--stdout]      Print to stdout
    [-r|--raw]      Print raw values delimited by commas
    [-d|--disk]     Show information for selected disk
                    Defaults to $(get_root)
    [-m|--mount]    Show information for selected mount
    [-h|--help]     Show this message
"
}

get_args()
{
    while (($# > 0)); do
        case "$1" in
            "--stdout")     stdout="true" ;;
            "-r"|"--raw")   raw="true" ;;
            "-d"|"--disk")  type="disk"; search="$2" ;;
            "-m"|"--mount") type="mount"; search="$2" ;;
            "-h"|"--help")  print_usage; exit ;;
        esac
        shift
    done
}

main()
{
    ! check_apps && exit 1
    get_args "$@"

    mapfile -t df_out < <(df -P -k)

    if get_search "${search}"; then
        get_disk_info
    else
        return 1
    fi

    [[ "${disk_device}" == "" \
    || "${disk_capacity}" == "0.00" \
    ]] && exit 1

    [[ "${raw}" ]] && {
        printf -v out "%s," \
            "${disk_name}" \
            "${disk_mount}" \
            "${disk_used} GiB" \
            "${disk_capacity} GiB" \
            "${disk_percent}%" \
            "${disk_device}"
        printf -v out "%s%s" "${out}" "${disk_part}"
        printf "%s\\n" "${out}"
        exit 0
    }

    [[ "${disk_name}" ]] && \
        title_parts+=("${disk_name}")

    [[ "${disk_mount}" ]] && \
        title_parts+=("(${disk_mount})")

    [[ "${disk_used}" ]] && \
        subtitle_parts+=("${disk_used}" "GiB")

    [[ "${disk_capacity}" ]] && \
        subtitle_parts+=("|" "${disk_capacity}" "GiB")

    [[ "${disk_percent}" ]] && \
        subtitle_parts+=("(${disk_percent}%)")

    [[ "${disk_device}" ]] && \
        message_parts+=("${disk_device}")

    [[ "${disk_part}" ]] && \
        message_parts+=("|" "${disk_part}")

    notify
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && \
    main "$@"
