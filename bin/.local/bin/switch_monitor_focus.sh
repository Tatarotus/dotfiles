#!/bin/bash

# Get the monitor to focus on (1 or 2)
MONITOR=$1

# List all windows with their geometry and details
WINDOWS=$(wmctrl -lG)

if [ "$MONITOR" == "1" ]; then
    # Find a window on the first monitor (leftmost, starting at x=0)
    TARGET_WINDOW=$(echo "$WINDOWS" | awk '$3 == 0 {print $1}' | head -n 1)
elif [ "$MONITOR" == "2" ]; then
    # Find a window on the second monitor (right, starting at x >= 1280)
    TARGET_WINDOW=$(echo "$WINDOWS" | awk '$3 >= 1280 {print $1}' | head -n 1)
fi

# Activate the window if found
if [ -n "$TARGET_WINDOW" ]; then
    wmctrl -ia "$TARGET_WINDOW"
else
    echo "No window found on monitor $MONITOR"
fi
