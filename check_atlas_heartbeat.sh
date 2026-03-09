#!/bin/bash
# check_atlas_heartbeat.sh
# Query Supabase for Atlas heartbeat status
# Returns: status,last_seen_timestamp or "unreachable" if Supabase fails

set -e

# Load environment variables
if [ -f ~/.openclaw/.env ]; then
    export $(grep -v '^#' ~/.openclaw/.env | xargs)
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "ERROR: Missing Supabase credentials in ~/.openclaw/.env"
    exit 1
fi

# Query Supabase for most recent Atlas heartbeat
response=$(curl -s -X GET "$SUPABASE_URL/rest/v1/agent_status?agent_name=eq.atlas&select=status,last_seen&order=last_seen.desc&limit=1" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -H "Content-Type: application/json" 2>/dev/null || echo "unreachable")

if [ "$response" = "unreachable" ]; then
    echo "unreachable"
    exit 0
fi

# Parse response (expecting JSON array with status and last_seen)
if echo "$response" | grep -q '"status"'; then
    status=$(echo "$response" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    last_seen=$(echo "$response" | grep -o '"last_seen":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "$status,$last_seen"
else
    echo "no_data"
fi
