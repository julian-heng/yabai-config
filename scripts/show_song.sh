#!/usr/bin/env bash
# shellcheck disable=1090,2194

check_apps()
{
    if ! type -p osascript > /dev/null; then
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

check_app_state()
{
    match="false"

   if pgrep -x "cmus" > /dev/null; then
        app="cmus"
        app_state="$(awk '/status/ {print $2}' < <(cmus-remote -Q))"
        match="true"
    elif [[ "$(osascript -e "application \"Music\" is running")" == "true" ]]; then
        app="Music"
        app_state="$(osascript -e "tell application \"Music\" to player state as string")"
        match="true"
    elif [[ "$(osascript -e "application \"Spotify\" is running")" == "true" ]]; then
        app="Spotify"
        app_state="$(osascript -e "tell application \"Spotify\" to player state as string")"
        match="true"
    fi

    [[ "${match}" != "true" ]] && \
        app_state="none"
}

get_song_info()
{
    if [[ "${app}" == "cmus" ]]; then
        IFS=":" \
        read -r track \
                artist \
                album \
                < <(cmus-remote -C "format_print %{title}:%{artist}:%{album}")
    else
        track_cmd="name of current track as string"
        artist_cmd="artist of current track as string"
        album_cmd="album of current track as string"

        osa_script="tell application \"${app}\"
                        ${track_cmd} & \":\" & \
                        ${artist_cmd} & \":\" & \
                        ${album_cmd}
                    end tell"

        IFS=":" \
        read -r track \
                artist \
                album \
                < <(/usr/bin/env osascript <<< "${osa_script}")
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

    check_app_state

    case "${app_state}" in
        "none"|"stopped")
            title_parts=("Now Playing")
            subtitle_parts=()
            message_parts=("No Music Playing")
         ;;

        *)
            get_song_info
            title_parts+=("Now Playing")

            if [[ "${artist}" ]]; then
                subtitle_parts+=("${artist}")
                [[ "${track}" ]] && \
                    subtitle_parts+=("-" "${track}")
            elif [[ "${track}" ]]; then
                subtitle_parts+=("${track}")
            fi

            [[ "${album}" ]] && \
                message_parts+=("${album}")
        ;;
    esac

    [[ "${raw}" ]] && {
        printf -v out "%s," \
            "${app}" \
            "${app_state}" \
            "${artist}" \
            "${album}"
        printf -v out "%s%s" "${out}" "${track}"
        printf "%s\\n" "${out}"
        exit 0
    }

    notify
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
    main "$@"
