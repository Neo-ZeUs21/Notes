#!/bin/bash

file="input_video.mp4"
capture_interval="10s"
max_captures_per_sheet=200

# Get video duration using FFprobe
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" | awk '{printf "%.0f\n", $0}')

# Calculate the number of contact sheets needed
num_sheets=$((duration / 1800))  # Divide duration by 30 minutes
remainder=$((duration % 1800))  # Remainder of duration divided by 30 minutes

if ((remainder > 0)); then
    num_sheets=$((num_sheets + 1))
fi

# Generate contact sheets for each 30 minutes
for ((sheet=1; sheet<=num_sheets; sheet++)); do
    start=$(( (sheet-1) * 1800 ))  # Start time for the current 30-minute interval

    if ((sheet == num_sheets && remainder > 0)); then
        end=$((start + remainder))  # End time for the last interval (considering remainder)
    else
        end=$((start + 1800))  # End time for other intervals
    fi

    # Generate a contact sheet using VCS for the specified time range
    vcs "$file" -U0 -i "$capture_interval" -c 4 -f "${start}s" -t "${end}s" -H 540 -j
done
