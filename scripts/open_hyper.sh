#!/usr/bin/env bash

# Detects if Hyper is running
if ! pgrep -f "Hyper" > /dev/null; then
    open -a "/Applications/Hyper.app"
else
    # Create a new window
    if ! osascript -e 'tell application "Hyper" to create window with default profile' > /dev/null; then
        # Get pids for any app with "iTerm" and kill
        for i in $(pgrep -f "Hyper"); do kill -15 "$i"; done
        open  -a "/Applications/Hyper.app"
    fi
fi
