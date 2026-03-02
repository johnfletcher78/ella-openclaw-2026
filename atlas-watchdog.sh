#!/bin/bash
# Atlas Watchdog - Recovers stuck tasks

IN_PROGRESS="$HOME/.openclaw/shared/tasks/in-progress"
PENDING="$HOME/.openclaw/shared/tasks/pending"
NOW=$(date +%s)

for task_file in "$IN_PROGRESS"/*.json; do
    [ -f "$task_file" ] || continue
    
    created=$(jq -r '.created // empty' "$task_file")
    timeout=$(jq -r '.timeout // 3600' "$task_file")
    
    if [ -z "$created" ]; then
        continue
    fi
    
    # Parse ISO timestamp to epoch
    created_epoch=$(date -d "$created" +%s 2>/dev/null || echo "0")
    deadline=$((created_epoch + timeout))
    
    if [ "$NOW" -gt "$deadline" ]; then
        echo "[$(date)] Watchdog: Task timed out, returning to pending: $(basename $task_file)"
        mv "$task_file" "$PENDING/"
    fi
done
