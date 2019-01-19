#!/usr/bin/env bash

# Detects if iTerm2 is running
if ! pgrep -f "iTerm" > /dev/null; then
    open -a "/Applications/iTerm.app"
else
    # Create a new window
    if ! osascript -e 'tell application "iTerm2" to create window with default profile' > /dev/null; then
        # Get pids for any app with "iTerm" and kill
        for i in $(pgrep -f "iTerm"); do kill -15 "$i"; done
        open  -a "/Applications/iTerm.app"
    fi
fi
