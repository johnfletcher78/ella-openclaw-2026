#!/bin/bash
# is_heartbeat_fresh.sh
# Check if Atlas heartbeat is under 2 minutes old
# Usage: is_heartbeat_fresh.sh <iso_timestamp>
# Returns: "fresh" or "stale"

heartbeat_time="$1"

if [ -z "$heartbeat_time" ]; then
    echo "stale"
    exit 0
fi

# Convert heartbeat time to epoch seconds
heartbeat_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${heartbeat_time:0:19}" +%s 2>/dev/null || date -d "$heartbeat_time" +%s 2>/dev/null)

# Get current time in epoch seconds
current_epoch=$(date +%s)

# Calculate difference
diff=$((current_epoch - heartbeat_epoch))

# Threshold: 120 seconds (2 minutes)
if [ $diff -lt 120 ]; then
    echo "fresh"
else
    echo "stale"
fi
