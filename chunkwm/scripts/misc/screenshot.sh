#!/usr/bin/env bash

function get_args
{
    [[ -z "$1" ]] && exit 1
    while [[ "$1" ]]; do
        case "$1" in
            "-f"|"--fullscreen")  mode="fullscreen" ;;
            "-s"|"--selection")   mode="selection" ;;
            "-c"|"--clipboard")   clipboard="true" ;;
            "-d"|"--dir")         dir="$2"; shift ;;
        esac
        shift
    done
}

function check_dir
{
    [[ "${dir}" ]] && dir="${HOME}/Desktop" && return 0
    if [[ ! -d "${dir}" ]]; then
        title_parts=("Screenshot failed")
        subtitle_parts=()
        message_parts=("${dir}" "is not a valid directory")

        title="$(format "${title_parts[@]}")"
        subtitle="$(format "${subtitle_parts[@]}")"
        message="$(format "${message_parts[@]}")"

        notify "${title:-}" "${subtitle:-}" "${message:-}"
        exit 1
    fi
}

function take_screenshot
{
    local name
    local filename

    # Create the filename
    printf -v name "%(Screen Shot %Y-%m-%d at%l.%M.%S %p)T" -1
    filename="${dir}/${name}.png"

    # Remove chunkwm borders
    chunkc border::clear

    case "${1:0:1}${2:0:1}" in
        "f")   screencapture -mx "${filename}" ;;
        "s")   screencapture -ix "${filename}" ;;
        "ft")  screencapture -mxc "${filename}" ;;
        "st")  screencapture -ixc "${filename}" ;;
    esac
}

function main
{
    ! { source "${BASH_SOURCE[0]//${0##*/}/}../display/notify.sh" \
        && source "${BASH_SOURCE[0]//${0##*/}/}../display/format.sh"; } \
            && exit 1

    get_args "$@"
    check_dir
    take_screenshot "${mode}" "${clipboard}"
}

main "$@"
