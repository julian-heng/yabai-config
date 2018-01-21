#!/usr/bin/env bash

# Detects if iTerm2 is running
if ! pgrep -f "iTerm" > /dev/null; then
    open "/Applications/iTerm.app" 
else
    # Create a new window
    osascript -e 'tell application "iTerm2" to create window with default profile' > /dev/null

    # If that fails
    if (($? == 1)); then

        # Get pids for any app with "iTerm"
        i=("$(pgrep -f "iTerm")")
        while read -r j; do
            # Kill all pids for any app with "iTerm"
            kill -9 "$j"
        done < <(printf "%s\\n" "${i[@]}")
        open "/Applications/iTerm.app" 

    fi
fi