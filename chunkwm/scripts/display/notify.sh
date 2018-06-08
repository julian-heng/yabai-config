#!/usr/bin/env bash

function notify
{
    local title="$1"
    local subtitle="$2"
    local content="$3"

    /usr/bin/env osascript << EOF
        display notification "${content}" with title "${title}" subtitle "${subtitle}"
EOF
}
