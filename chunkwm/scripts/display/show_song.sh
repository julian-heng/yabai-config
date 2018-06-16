#!/usr/bin/env bash
# shellcheck disable=1090,2194

function count_char
{
    : "${*}"
    printf "%s" "${#_}"
}

function check_app_state
{
    local -a apps
    local app
    local app_state
    local match="false"

    if [[ "$1" ]]; then
        apps=("$@")
    else
        apps=("Spotify" "iTunes" "cmus")
    fi

    while read -r in_app && [[ "${match}" != "true" ]]; do
       if [[ "${in_app}" == "cmus" ]]; then
            pgrep -x "cmus" > /dev/null && {
                app="cmus"
                app_state="$(awk '/status/ {print $2}' < <(cmus-remote -Q))"
                match="true"
            }
        elif [[ "$(osascript -e "application \"${in_app}\" is running")" == "true" ]]; then
            app="${in_app}"
            app_state="$(osascript -e "tell application \"${in_app}\" to player state as string")"
            match="true"
        fi
    done < <(printf "%s\\n" "${apps[@]}")

    [[ "${match}" != "true" ]] && {
        if ((${#apps[@]} != 1)); then
            app="none"
            app_state="none"
        else
            app="${apps[0]}"
            app_state="stopped"
        fi
    }

    printf "%s;%s" \
        "${app}" \
        "${app_state}"
}

function get_song_info
{
    local app="$1"
    local track
    local artist
    local album

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

        IFS=":" \
        read -r track \
                artist \
                album \
                < <(/usr/bin/env osascript << EOF
                        tell application "${app}"
                            ${track_cmd} & ":" & \
                            ${artist_cmd} & ":" & \
                            ${album_cmd}
                        end tell
EOF
)
    fi

    printf "%s;%s;%s" \
        "${track}" \
        "${artist}" \
        "${album}"
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}}notify.sh" && \
        source "${BASH_SOURCE[0]//${0##*/}}format.sh"; } && \
            exit 1

    IFS=";" \
    read -r app \
            state \
            < <(check_app_state "$@")

    if [[ "${state}" =~ ^(playing|paused)$ ]]; then
        IFS=";" \
        read -r track \
                artist \
                album \
                < <(get_song_info "${app}")

        if [[ "${state}" == "paused" ]]; then
            title_parts=("Now Playing on" "${app}" "(" "${state}" ")")
        else
            title_parts=("Now Playing on" "${app}")
        fi
        subtitle_parts=("${artist}" "-" "${track}")
        message_parts=("${album}")

        (("$(count_char "${subtitle_parts[@]}")" >= 50)) && {
            subtitle_parts=("${track}")
            message_parts=("${artist}" "-" "${album}")
        }

        (("$(count_char "${message_parts[@]}")" >= 50)) && {
            message_parts=("${artist}")
        }
    else
        if [[ "${state}" == "none" ]]; then
            title_parts=("Now Playing")
        elif [[ "${state}" == "stopped" ]]; then
            title_parts=("Now Playing on" "${app}")
        fi
        subtitle_parts=()
        message_parts=("${artist}")
    fi

    title="$(format "${title_parts[@]}")"
    subtitle="$(format "${subtitle_parts[@]}")"
    message="$(format "${message_parts[@]}")"

    notify "${title:-}" "${subtitle:-}" "${message:-}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && \
    main "$@" || :
