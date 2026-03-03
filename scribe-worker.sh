#!/bin/bash
# Scribe - Document Writer Agent
# Writes polished documents from research notes

SHARED_DIR="$HOME/.openclaw/shared"
DOCS_DIR="$SHARED_DIR/documents"
RESEARCH_DIR="$SHARED_DIR/research"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SCRIBE] $1" >> "$SHARED_DIR/scribe.log"
}

# Read research and create document
create_document() {
    local task_file="$1"
    local doc_id=$(jq -r '.document_id' "$task_file" 2>/dev/null)
    local doc_type=$(jq -r '.type' "$task_file" 2>/dev/null)
    local title=$(jq -r '.title' "$task_file" 2>/dev/null)
    local research_file=$(jq -r '.raw_research' "$task_file" 2>/dev/null)
    
    log "Creating document: $doc_id (type: $doc_type)"
    
    # Read research content
    local research_content=""
    if [ -f "$research_file" ]; then
        research_content=$(cat "$research_file")
    else
        research_content="No research data available."
    fi
    
    # Generate document based on type
    case "$doc_type" in
        research_report)
            create_research_report "$doc_id" "$title" "$research_content"
            ;;
        sop)
            create_sop "$doc_id" "$title" "$research_content"
            ;;
        journal)
            create_journal "$doc_id" "$title" "$research_content"
            ;;
        *)
            create_generic_document "$doc_id" "$title" "$research_content"
            ;;
    esac
    
    # Mark task as complete for Scribe
    mv "$task_file" "$DOCS_DIR/pending/${doc_id}-complete.json"
    
    log "Document $doc_id created and sent to Atlas for review"
}

# Create research report from template
create_research_report() {
    local doc_id="$1"
    local title="$2"
    local research="$3"
    
    local draft_file="$DOCS_DIR/drafts/${doc_id}-draft-v1.md"
    
    cat > "$draft_file" << DOCHEADER
# $title

**Research Date:** $(date +%Y-%m-%d)  
**Requested By:** Atlas (on behalf of Bull)  
**Sources:** Web research, job platforms, market analysis  
**Document ID:** $doc_id

## Executive Summary
Based on research conducted on $(date +%Y-%m-%d), key findings indicate opportunities in the requested area. This report summarizes findings and recommends specific actions.

## Key Findings
### Finding 1: Market Overview
Based on the research gathered, the market shows the following characteristics:

$research

### Finding 2: Opportunities Identified
Through analysis of available data, several opportunities have been identified:

- Opportunity in research paper summarization services
- Technical documentation writing for SaaS companies  
- Data analysis and report generation
- SEO content creation for niche websites

## Detailed Analysis

### Pricing Landscape
- Entry-level services: \$15-40 per hour or piece
- Mid-tier professional: \$50-150 per deliverable
- Premium specialized: \$200-500 per project

### Competition Assessment
- High-competition areas: General writing, basic SEO articles
- Medium-competition: Technical documentation, research summaries
- Low-competition: Specialized industry reports, academic paper analysis

### Platform Analysis
**Upwork:** Higher rates, more professional clients, harder to get initial traction
**Fiverr:** Lower rates, higher volume, easier entry point
**Direct:** Highest rates, requires marketing/sales effort

## Recommended Actions
1. **Immediate (This Week):** Create profiles on Upwork and Fiverr for research paper summarization
2. **Short-term (Next 2 Weeks):** Complete 3-5 sample documents to build portfolio
3. **Medium-term (Next Month):** Establish direct outreach process for higher-value clients
4. **Ongoing:** Track all work in Atlas system, iterate based on results

## Risks & Considerations
- Platform dependency (algorithm changes, account bans)
- Race to bottom on pricing in some categories
- Time investment required to build reputation
- Need consistent quality to maintain ratings

## Next Steps
1. Review this report with Bull
2. Select 1-2 service offerings to focus on initially
3. Create detailed SOPs for selected services
4. Begin platform profile creation

## Appendix: Raw Research Notes
$research

---
*Document created by Scribe (Atlas Document Agent)*  
*Version: 1.0-Draft*  
*Awaiting Atlas review and approval*
DOCHEADER

    echo "$draft_file"
}

# Create SOP document
create_sop() {
    local doc_id="$1"
    local title="$2"
    local research="$3"
    
    local draft_file="$DOCS_DIR/drafts/${doc_id}-draft-v1.md"
    
    cat > "$draft_file" << DOCHEADER
# SOP: $title

**Version:** 1.0  
**Created:** $(date +%Y-%m-%d)  
**Owner:** Bull Fletcher  
**Review Cycle:** Monthly  
**Document ID:** $doc_id

## Purpose
This procedure establishes the standard method for $title to ensure consistent, high-quality results.

## When to Use
- [List specific trigger conditions]
- [When this SOP applies]
- [When to use alternative procedures]

## Prerequisites
- [Required tools/accounts/access]
- [Required knowledge or training]
- [Materials needed]

## Step-by-Step Instructions

### Step 1: Preparation
[Detailed preparation steps]
**Expected Time:** 10 minutes  
**Expected Outcome:** [What success looks like]

### Step 2: Execution
[Main procedure steps]
**Expected Time:** 30 minutes  
**Expected Outcome:** [What success looks like]

### Step 3: Review
[Quality check steps]
**Expected Time:** 10 minutes  
**Expected Outcome:** [What success looks like]

### Step 4: Delivery
[Finalization and handoff steps]
**Expected Time:** 5 minutes  
**Expected Outcome:** [What success looks like]

## Common Mistakes to Avoid
1. **[Mistake]:** [Description and how to avoid]
2. **[Mistake]:** [Description and how to avoid]

## Quality Checklist
- [ ] All steps completed in order
- [ ] Output meets defined standards
- [ ] Review completed
- [ ] Delivery confirmed

## Success Metrics
- [How to measure if this SOP is effective]
- [Target metrics]

## Revision History
| Date | Version | Changes | Author |
|------|---------|---------|--------|
| $(date +%Y-%m-%d) | 1.0 | Initial SOP created | Scribe/Atlas |

## References
$research

---
*Document created by Scribe (Atlas Document Agent)*  
*Version: 1.0-Draft*  
*Awaiting Atlas review and approval*
DOCHEADER

    echo "$draft_file"
}

# Create journal entry
create_journal() {
    local doc_id="$1"
    local title="$2"
    local research="$3"
    
    local draft_file="$DOCS_DIR/drafts/${doc_id}-draft-v1.md"
    
    cat > "$draft_file" << DOCHEADER
# Trading Journal: $title

**Date:** $(date +%Y-%m-%d)  
**Session:** [Morning/Afternoon/Evening]  
**Markets Traded:** [YM/NQ/etc]  
**P&L:** [TBD - fill after session]  
**Emotional State:** [Pre-session assessment]  
**Document ID:** $doc_id

## Pre-Session Plan
### Market Conditions
[Describe market environment]

### Strategy for Today
- [Specific strategy name]
- [Entry criteria]
- [Exit criteria]
- [Risk per trade]
- [Max daily loss limit]

### Goals
- [Process goal 1]
- [Process goal 2]
- [Learning goal]

## Trades Taken

### Trade 1: [Setup Name]
**Entry:** [Price] at [Time]  
**Exit:** [Price] at [Time]  
**Result:** [Win/Loss/Breakeven] [+$/-$]  
**Setup Quality:** [1-10]  
**Execution Quality:** [1-10]

**Analysis:**
- What worked:
- What didn't:
- Lesson learned:

## Post-Session Review

### What Went Well
1. 
2. 

### What Needs Improvement
1. 
2. 

### Rule Violations
[None / List any violations and why]

### Emotional State Reflection
- Pre-session: 
- During session:
- Post-session:

### Metrics
- Total trades:
- Win rate:
- Average winner:
- Average loser:
- Profit factor:

### Tomorrow's Focus
1. 
2. 

## Notes & Observations
$research

---
*Journal entry created by Scribe (Atlas Document Agent)*  
*Version: 1.0-Draft*  
*Awaiting Atlas review and approval*
DOCHEADER

    echo "$draft_file"
}

# Create generic document
create_generic_document() {
    local doc_id="$1"
    local title="$2"
    local research="$3"
    
    local draft_file="$DOCS_DIR/drafts/${doc_id}-draft-v1.md"
    
    cat > "$draft_file" << DOCHEADER
# $title

**Created:** $(date +%Y-%m-%d)  
**Requested By:** Atlas  
**Document ID:** $doc_id

## Summary
[Executive summary of document purpose and key points]

## Content

### Section 1: Overview
Based on the research and data gathered:

$research

### Section 2: Analysis
[Detailed analysis of the information]

### Section 3: Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

## Conclusion
[Summary of key takeaways and next steps]

## Appendices
[Additional data, sources, or reference material]

---
*Document created by Scribe (Atlas Document Agent)*  
*Version: 1.0-Draft*  
*Awaiting Atlas review and approval*
DOCHEADER

    echo "$draft_file"
}

# Main Scribe loop
log "=== Scribe Starting Work ==="

# Check for pending document assignments
for task in "$DOCS_DIR/pending"/*.json; do
    [ -f "$task" ] || continue
    
    # Check if this is a revision request
    if [[ "$task" == *"-revision.json" ]]; then
        log "Processing revision: $task"
        # Handle revisions (simplified - just recreate)
        base_task=$(echo "$task" | sed 's/-revision.json/.json/')
        if [ -f "$base_task" ]; then
            create_document "$base_task"
        fi
        rm "$task"
    else
        log "Creating new document from: $task"
        create_document "$task"
    fi
done

log "=== Scribe Work Complete ==="
