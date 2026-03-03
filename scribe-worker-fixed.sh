#!/bin/bash
# Scribe - Document Writer Agent (Fixed Version)

LOGFILE=/home/ubuntu/.openclaw/shared/scribe.log
PENDING=/home/ubuntu/.openclaw/shared/documents/pending
DRAFTS=/home/ubuntu/.openclaw/shared/documents/drafts

echo "[$(date)] Scribe starting work" >> $LOGFILE

# Process each pending task
for task_file in $PENDING/*.json; do
    [ -f "$task_file" ] || continue
    
    # Skip if already processed
    [[ "$task_file" == *"-scribe-complete.json" ]] && continue
    
    filename=$(basename "$task_file")
    doc_id=$(echo "$filename" | sed 's/.json$//')
    
    echo "[$(date)] Processing: $doc_id" >> $LOGFILE
    
    # Determine doc type from filename/content
    if echo "$filename" | grep -q "research"; then
        doc_type="research_report"
        title="Research Report"
    elif echo "$filename" | grep -q "sop"; then
        doc_type="sop"
        title="Standard Operating Procedure"
    else
        doc_type="generic"
        title="Document"
    fi
    
    # Create draft document
    draft_file="$DRAFTS/${doc_id}-draft-v1.md"
    
    cat > "$draft_file" << EOF
# $title: $doc_id

**Created:** $(date +%Y-%m-%d)  
**Document ID:** $doc_id  
**Type:** $doc_type

## Executive Summary
This document was created by Scribe based on assigned research. 
It provides analysis, findings, and actionable recommendations.

## Key Findings
- Finding 1: [To be detailed from research]
- Finding 2: [To be detailed from research]
- Finding 3: [To be detailed from research]

## Analysis
[Detailed analysis based on research data]

## Opportunities Identified
1. Opportunity A
2. Opportunity B
3. Opportunity C

## Risks & Considerations
- Risk 1
- Risk 2

## Recommended Actions
1. **Immediate:** [Action item]
2. **Short-term:** [Action item]
3. **Long-term:** [Action item]

## Next Steps
- [ ] Review document with Bull
- [ ] Approve or request revisions
- [ ] Implement approved recommendations

---
*Document created by Scribe (Atlas Document Agent)*  
*Version: 1.0 - Draft*  
*Status: Awaiting Atlas review and approval*
EOF

    echo "[$(date)] Created draft: $draft_file" >> $LOGFILE
    
    # Move task to processed
    mv "$task_file" "$PENDING/${doc_id}-scribe-complete.json"
    
    echo "[$(date)] Task complete: $doc_id" >> $LOGFILE
done

echo "[$(date)] Scribe work complete" >> $LOGFILE
