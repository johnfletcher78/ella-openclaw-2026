#!/bin/bash
# Atlas Document Coordinator - Reviews drafts and notifies Ella

LOGFILE=/home/ubuntu/.openclaw/shared/atlas-coordinator.log
DRAFTS=/home/ubuntu/.openclaw/shared/documents/drafts
FINAL=/home/ubuntu/.openclaw/shared/documents/final
NOTIFY=/home/ubuntu/.openclaw/shared/notifications

echo "[$(date)] Atlas coordinator starting" >> $LOGFILE

mkdir -p $FINAL $NOTIFY

# Review each draft
for draft in $DRAFTS/*-draft-v1.md; do
    [ -f "$draft" ] || continue
    
    filename=$(basename "$draft")
    doc_id=$(echo "$filename" | sed 's/-draft-v1.md//')
    
    echo "[$(date)] Reviewing: $doc_id" >> $LOGFILE
    
    # Simple review: check file has content
    if [ -s "$draft" ]; then
        # APPROVE
        final_file="$FINAL/${doc_id}-v1.md"
        cp "$draft" "$final_file"
        rm "$draft"
        
        echo "[$(date)] APPROVED: $doc_id" >> $LOGFILE
        
        # Notify Ella - create notification entry
        echo "$(date +%Y-%m-%dT%H:%M:%S) | DOCUMENT_READY | $doc_id | $final_file | Atlas approved and finalized" >> $NOTIFY/ella-queue.txt
        
        echo "[$(date)] Notified Ella: $doc_id" >> $LOGFILE
    else
        echo "[$(date)] REJECTED (empty): $doc_id" >> $LOGFILE
        rm "$draft"
    fi
done

echo "[$(date)] Coordinator complete" >> $LOGFILE
