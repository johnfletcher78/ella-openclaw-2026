#!/bin/bash
# Atlas Documents Data Generator
# Generates JSON data for the documents section of dashboard

SHARED_DIR="$HOME/.openclaw/shared"
OUTPUT_FILE="$SHARED_DIR/documents-data.json"

# Start JSON
echo '{' > "$OUTPUT_FILE"
echo '  "generated": "'$(date -Iseconds)'",' >> "$OUTPUT_FILE"
echo '  "documents": [' >> "$OUTPUT_FILE"

# Process finalized documents
first=true
for doc in "$SHARED_DIR/documents/final"/*.md; do
    [ -f "$doc" ] || continue
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    
    filename=$(basename "$doc")
    doc_id=$(echo "$filename" | sed 's/-v[0-9]*.md//' | sed 's/.md$//')
    
    # Get first line (title) if it exists
    title=$(head -1 "$doc" 2>/dev/null | sed 's/^# //' | head -c 80)
    if [ -z "$title" ]; then
        title="$filename"
    fi
    
    echo "    {\"id\": \"$doc_id\", \"filename\": \"$filename\", \"title\": \"$title\", \"path\": \"$doc\", \"modified\": \"$(stat -c %y "$doc" 2>/dev/null || stat -f %Sm "$doc" 2>/dev/null || echo 'unknown')\"}" >> "$OUTPUT_FILE"
done

echo '' >> "$OUTPUT_FILE"
echo '  ],' >> "$OUTPUT_FILE"

# Add drafts info
echo '  "drafts": [' >> "$OUTPUT_FILE"
first=true
for draft in "$SHARED_DIR/documents/drafts"/*-draft-v*.md; do
    [ -f "$draft" ] || continue
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    
    filename=$(basename "$draft")
    echo "    \"$filename\"" >> "$OUTPUT_FILE"
done
echo '  ]' >> "$OUTPUT_FILE"

echo '}' >> "$OUTPUT_FILE"

echo "Documents data updated: $OUTPUT_FILE"
