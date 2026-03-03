#!/bin/bash
# Atlas Dashboard Data Generator
# Generates JSON data for the dashboard from task queue

SHARED_DIR="$HOME/.openclaw/shared"
OUTPUT_FILE="$SHARED_DIR/atlas-data.json"

# Function to safely read JSON
read_task_json() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file"
    else
        echo "{}"
    fi
}

# Start JSON
echo '{' > "$OUTPUT_FILE"
echo '  "generated": "'$(date -Iseconds)'",' >> "$OUTPUT_FILE"
echo '  "pending": [' >> "$OUTPUT_FILE"

# Process pending tasks
first=true
for task in "$SHARED_DIR/tasks/pending"/*.json; do
    [ -f "$task" ] || continue
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    cat "$task" >> "$OUTPUT_FILE"
done

echo '' >> "$OUTPUT_FILE"
echo '  ],' >> "$OUTPUT_FILE"
echo '  "inProgress": [' >> "$OUTPUT_FILE"

# Process in-progress tasks
first=true
for task in "$SHARED_DIR/tasks/in-progress"/*.json; do
    [ -f "$task" ] || continue
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    cat "$task" >> "$OUTPUT_FILE"
done

echo '' >> "$OUTPUT_FILE"
echo '  ],' >> "$OUTPUT_FILE"
echo '  "done": [' >> "$OUTPUT_FILE"

# Process completed tasks (last 20, most recent first)
first=true
for task in $(ls -t "$SHARED_DIR/tasks/done"/*-result.json 2>/dev/null | head -20); do
    [ -f "$task" ] || continue
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi    
    # For done tasks, try to read the result JSON, fallback to empty
    if [ -f "$task" ]; then
        cat "$task" >> "$OUTPUT_FILE"
    fi
done

echo '' >> "$OUTPUT_FILE"
echo '  ]' >> "$OUTPUT_FILE"
echo '}' >> "$OUTPUT_FILE"

echo "Dashboard data updated: $OUTPUT_FILE"
