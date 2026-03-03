#!/bin/bash
# Atlas Document Workflow Coordinator
# Manages: Researcher → Scribe (Document Writer) → Review → Notify

SHARED_DIR="$HOME/.openclaw/shared"
DOCS_DIR="$SHARED_DIR/documents"
RESEARCH_DIR="$SHARED_DIR/research"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$SHARED_DIR/atlas-document-flow.log"
}

# Function to assign document to Scribe
assign_to_scribe() {
    local research_file="$1"
    local doc_id="doc-$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 4 | head -c 8)"
    local doc_type="$2"
    local title="$3"
    
    log "Assigning to Scribe: $doc_id"
    
    # Create handoff file for Scribe
    cat > "$DOCS_DIR/pending/${doc_id}.json" << SCRYBEOF
{
  "document_id": "$doc_id",
  "type": "$doc_type",
  "title": "$title",
  "raw_research": "$research_file",
  "requested_by": "atlas",
  "priority": "normal",
  "created": "$(date -Iseconds)",
  "status": "pending_scribe"
}
SCRYBEOF

    log "Document $doc_id queued for Scribe"
}

# Function for Atlas to review Scribe's draft
review_draft() {
    local draft_file="$1"
    local doc_id=$(basename "$draft_file" | sed 's/-draft-v[0-9]*.md//')
    
    log "Atlas reviewing draft: $doc_id"
    
    # Atlas performs quality checks
    local checks_passed=true
    local revision_notes=""
    
    # Check 1: Executive summary present
    if ! grep -q "## Executive Summary" "$draft_file" 2>/dev/null; then
        checks_passed=false
        revision_notes="$revision_notes\n- Missing Executive Summary"
    fi
    
    # Check 2: Action items present
    if ! grep -q "## Recommended Actions" "$draft_file" 2>/dev/null; then
        checks_passed=false
        revision_notes="$revision_notes\n- Missing Recommended Actions section"
    fi
    
    # Check 3: No placeholder text
    if grep -q "\[.*\]" "$draft_file" 2>/dev/null; then
        local placeholders=$(grep -o "\[.*\]" "$draft_file" | head -5)
        revision_notes="$revision_notes\n- Contains placeholders: $placeholders"
    fi
    
    if [ "$checks_passed" = true ]; then
        log "Atlas APPROVED: $doc_id"
        
        # Move to final
        local final_file="$DOCS_DIR/final/${doc_id}-v1.md"
        cp "$draft_file" "$final_file"
        rm "$draft_file"
        
        # Update status
        echo "{\"document_id\": \"$doc_id\", \"status\": \"approved\", \"final_path\": \"$final_file\", \"approved_at\": \"$(date -Iseconds)\"}" > "$DOCS_DIR/final/${doc_id}-meta.json"
        
        # Notify Ella
        notify_ella "$doc_id" "$final_file"
        
        return 0
    else
        log "Atlas REQUESTS REVISION: $doc_id"
        
        # Return to Scribe with notes
        echo "{\"document_id\": \"$doc_id\", \"status\": \"revision_needed\", \"revision_notes\": \"$revision_notes\", \"returned_at\": \"$(date -Iseconds)\"}" > "$DOCS_DIR/pending/${doc_id}-revision.json"
        
        return 1
    fi
}

# Function to notify Ella (via file that I'll check)
notify_ella() {
    local doc_id="$1"
    local final_path="$2"
    
    log "Notifying Ella: $doc_id"
    
    # Extract key takeaway from document
    local takeaway=$(grep -A2 "## Executive Summary" "$final_path" 2>/dev/null | tail -1 | head -c 200)
    
    cat > "$SHARED_DIR/notifications/${doc_id}-notification.json" << NOTIFEOF
{
  "type": "document_complete",
  "document_id": "$doc_id",
  "title": "$(grep "^# " "$final_path" 2>/dev/null | head -1 | sed 's/^# //')",
  "key_takeaway": "$takeaway",
  "file_path": "$final_path",
  "completed_at": "$(date -Iseconds)",
  "action_required": "Review document and approve or request changes"
}
NOTIFEOF

    # Also append to notification queue for dashboard
    echo "$(date '+%Y-%m-%d %H:%M:%S') | DOCUMENT READY | $doc_id | $takeaway" >> "$SHARED_DIR/notifications/queue.txt"
    
    log "Ella notification queued: $doc_id"
}

# Main workflow loop
log "=== Atlas Document Workflow Starting ==="

# Step 1: Check for completed research that needs writing
for research in "$RESEARCH_DIR"/*-complete.json; do
    [ -f "$research" ] || continue
    
    doc_type=$(jq -r '.document_type // "research_report"' "$research" 2>/dev/null || echo "research_report")
    title=$(jq -r '.title // "Untitled Research"' "$research" 2>/dev/null || echo "Untitled Research")
    
    assign_to_scribe "$research" "$doc_type" "$title"
    
    # Move research to processed
    mv "$research" "$RESEARCH_DIR/processed/"
done

# Step 2: Check for Scribe drafts awaiting review
for draft in "$DOCS_DIR/drafts"/*-draft-v*.md; do
    [ -f "$draft" ] || continue
    
    review_draft "$draft"
done

# Step 3: Generate document pipeline status for dashboard
cat > "$SHARED_DIR/document-pipeline-status.json" << PIPELINEEOF
{
  "generated": "$(date -Iseconds)",
  "pending_scribe": $(ls "$DOCS_DIR/pending"/*.json 2>/dev/null | wc -l),
  "in_review": $(ls "$DOCS_DIR/drafts"/*-draft-v*.md 2>/dev/null | wc -l),
  "approved_today": $(find "$DOCS_DIR/final" -name "*.md" -mtime -1 2>/dev/null | wc -l),
  "total_documents": $(ls "$DOCS_DIR/final"/*.md 2>/dev/null | wc -l),
  "awaiting_ella_review": $(ls "$SHARED_DIR/notifications"/*-notification.json 2>/dev/null | wc -l)
}
PIPELINEEOF

log "=== Atlas Document Workflow Complete ==="
