#!/usr/bin/env bash

function format
{
    local line
    local count
    while (($# > 0)); do
        case "$1" in
            "(")
                while read -r i && [[ "${i}" != ")" ]]; do
                    ((count++))
                done < <(printf "%s\\n" "$@")
                : "${*:1:$((count + 1))}"
                : " ${_// }"
            ;;
            *)
                [[ ! "$1" || "$1" == "%" || ! "${line}" ]] && : "$1" || \
                    : " $1"
            ;;
        esac
        line+="${_}"
        ((count++))
        while ((count > 0)); do
            ((count--)) && shift
        done
    done
    printf "%s" "${line}"
}
