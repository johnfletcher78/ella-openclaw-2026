#!/bin/bash
# atlas_status_check.sh
# Complete Atlas status check with Supabase heartbeat + fallback
# Decision tree:
# 1. Check Supabase heartbeat
# 2. If fresh (< 2 min) → Atlas online, exit 0
# 3. If stale/missing → attempt direct Atlas connection
# 4. If Supabase unreachable → attempt direct Atlas connection
# 5. If both fail → true outage, exit 1 (alert needed)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load Atlas gateway token
if [ -f ~/.openclaw/.env ]; then
    export $(grep -v '^#' ~/.openclaw/.env | xargs)
fi

echo "Checking Atlas status..."

# Step 1: Check Supabase heartbeat
heartbeat_result=$($SCRIPT_DIR/check_atlas_heartbeat.sh)

if [ "$heartbeat_result" = "unreachable" ]; then
    echo "Supabase unreachable, falling back to direct Atlas connection..."
    supabase_ok=false
elif [ "$heartbeat_result" = "no_data" ]; then
    echo "No heartbeat data in Supabase, falling back to direct Atlas connection..."
    supabase_ok=false
else
    # Parse status and timestamp
    status=$(echo "$heartbeat_result" | cut -d',' -f1)
    last_seen=$(echo "$heartbeat_result" | cut -d',' -f2)
    
    # Check freshness
    freshness=$($SCRIPT_DIR/is_heartbeat_fresh.sh "$last_seen")
    
    if [ "$freshness" = "fresh" ]; then
        echo "Atlas heartbeat fresh (under 2 min) — Atlas is online"
        echo "Method: Supabase heartbeat"
        exit 0
    else
        echo "Atlas heartbeat stale ($last_seen), attempting direct connection..."
        supabase_ok=false
    fi
fi

# Step 2: Attempt direct Atlas connection
if [ -z "$ATLAS_GATEWAY_TOKEN" ]; then
    echo "ERROR: ATLAS_GATEWAY_TOKEN not set"
    exit 1
fi

# Try to reach Atlas gateway
atlas_response=$(curl -s -X POST "http://100.91.251.41:18790/rpc" \
    -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"health\",\"id\":1}" 2>/dev/null || echo "unreachable")

if echo "$atlas_response" | grep -q '"result"'; then
    echo "Atlas direct connection successful"
    echo "Method: Direct connection (Supabase fallback)"
    if [ "$supabase_ok" = "false" ]; then
        echo "Note: Supabase was unreachable but Atlas is online"
    fi
    exit 0
else
    # Step 3: Both failed — true outage
    echo "CRITICAL: Both Supabase and Atlas are unreachable"
    echo "Status: TRUE OUTAGE"
    exit 1
fi
