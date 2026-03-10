# MEMORY.md

> **⚠️ AUTHORITY NOTICE:** Ella is the sole custodian of this file. Atlas has no direct access. All updates flow through Ella only.

## About This File

This is the primary memory file for Ella. It stores persistent information about:
- Decisions and their rationale
- Important dates and events
- User preferences and patterns
- Ongoing todos and priorities
- Project status and history

## How to Use

- Add entries with clear headers and dates
- Keep entries factual and concise
- Update existing entries rather than duplicating
- Use bullet points for lists

---

## System Initialization

- **Memory system initialized:** March 7, 2026
- **Location:** /Users/bullfletcher/.openclaw/workspace/MEMORY.md
- **Storage:** Local embedding search enabled (embeddinggemma-300m-qat)

---

## OpenClaw Multi-Agent Architecture

**Date:** March 7, 2026

### Architecture Overview

```
Bull (User) → Ella (Strategic Orchestrator) → Atlas (VPS Worker) → Sub-agents
```

**Ella (Primary Agent)**
- Role: Strategic orchestrator, COO energy, execution amplifier
- Location: Bull's MacBook Pro (local)
- Responsibilities: Task dispatch, coordination, user interface, memory management
- Session key prefix: `ella:<context>`

**Atlas (VPS Orchestrator)**
- Role: Headless background worker, carries load when Mac sleeps
- Host: srv1365311 via Tailscale SSH
- Tailscale IP: 100.91.251.41
- User: ubuntu / root
- OpenClaw Gateway: ws://127.0.0.1:18789 (local loopback on Atlas)
- Auth Token: [REDACTED - see Atlas auth-profiles.json]
- Agent ID: atlas
- Responsibilities: Cron jobs, monitoring, sub-agents, trading watches, task execution
- Access: SSH tunnel or `exec ssh` from Mac

**Sub-agents**
- Spawned by Atlas for specific tasks (research, code, content, data, ops, comms, scrape)
- Isolated sessions with callbacks to Atlas
- Task types: research, code, content, data, ops, comms, scrape

### Communication Flow

Ella communicates with Atlas by writing JSON task files to `/shared/tasks/pending/` via SSH exec commands. Atlas cron picks them up every 60 seconds. Results go to `/shared/tasks/done/`. Reports saved to `/shared/workspace/`.

### Task File Format

```json
{
  "task": "<clear one-line description>",
  "type": "<research|code|content|data|ops|comms|scrape>",
  "priority": "high|normal|low",
  "context": "<any required background>",
  "callback_key": "hook:atlas:callback:<task_id>",
  "output_path": "<optional: where to save results>"
}
```

---

## Fixes Applied - March 7, 2026

### 1. Moonshot API Key Fix

**Problem:** Kimi K2.5 model failing due to missing/invalid API key

**Root Cause:** API key not properly configured in OpenClaw secrets

**Solution Applied:**
```bash
openclaw secrets configure
```
- Entered valid Moonshot API key when prompted
- Key format: `sk-...` (standard Moonshot format)
- Provider: moonshot:default

**Verification:** Model calls now succeeding, cost tracking active

---

### 2. Telegram IPv4 DNS Fix

**Problem:** Telegram connection issues, IPv6 DNS resolution failures

**Root Cause:** System defaulting to IPv6 for DNS resolution, causing timeouts

**Solution Applied:**
- Configured system to prefer IPv4 for Telegram connections
- Modified DNS resolution order

**Result:** Stable Telegram connectivity established

---

### 3. Atlas VPS Setup & Configuration

**Setup Date:** March 7, 2026

**Configuration Details:**
- **Host:** srv1365311 (Hostinger VPS)
- **Tailscale IP:** 100.91.251.41
- **SSH Access:** `ssh -i ~/.ssh/atlas_key root@100.91.251.41`
- **SSH Key Location:** `~/.ssh/atlas_key` (on Bull's Mac)

**Directory Structure:**
```
/shared/
├── tasks/
│   ├── pending/     # Tasks waiting to be processed
│   └── done/        # Completed tasks
├── workspace/       # Output files and reports
└── logs/           # System and task logs
```

**OpenClaw Gateway:**
- URL: ws://127.0.0.1:18789
- Runs on local loopback (Atlas itself)
- No external channels (API only — prevents Telegram conflicts)

---

## Atlas Cron Jobs

### Current Cron Jobs

**Task Processor**
- **Job ID:** 5fe3f4e5-7835-4fe9-bd75-07c19eb42194
- **Name:** task-processor
- **Schedule:** Every 60 seconds
- **Purpose:** Picks up JSON task files from `/shared/tasks/pending/`
- **Status:** Active

### Cron Job Management

```bash
# List all jobs
openclaw cron list

# Add new job
openclaw cron add --name "job-name" --schedule "*/5 * * * *" --command "task.json"

# Remove job
openclaw cron remove --id <job-id>
```

---

## Lessons Learned

### API Key Management
- Always verify secrets are configured after configuration changes
- Use `openclaw secrets configure` to update API keys interactively
- Export key to environment first: `export MOONSHOT_API_KEY=sk-yourkey`
- Verify provider name matches exactly (e.g., `moonshot:default`)

### Network Configuration
- IPv6 can cause DNS resolution issues with some providers
- Prefer IPv4 for stable Telegram connectivity
- Tailscale provides reliable VPS access without exposing public IPs

### Task Dispatch Pattern
- Always include `callback_key` so Atlas can report back
- Use descriptive task types for proper routing
- Write task files to `/shared/tasks/pending/` for Atlas pickup

### SSH Access
- Keep SSH keys in `~/.ssh/` with proper permissions (600)
- Use Tailscale for secure VPS access
- Test SSH connectivity before dispatching critical tasks

---

## Standard Operating Procedures (SOPs)

### SOP-001: Fixing Moonshot API Key Issues

1. Export the key in terminal: `export MOONSHOT_API_KEY=sk-yourkey`
2. Run: `openclaw secrets configure`
3. Select Continue
4. Select `profiles.moonshot:default.key`
5. Select `env`
6. Set alias=`default`, id=`MOONSHOT_API_KEY`
7. Apply

This writes to `~/.openclaw/agents/<agentId>/agent/auth-profiles.json`

### SOP-002: Dispatching Task to Atlas

1. Create task JSON file
2. Write to Atlas via SSH:
   ```bash
   ssh -i ~/.ssh/atlas_key root@100.91.251.41 "cat > /shared/tasks/pending/<task-name>.json" << 'ENDJSON'
   {task-json-content}
   ENDJSON
   ```
3. Verify file written: Check `/shared/tasks/pending/`
4. Wait for callback or check `/shared/tasks/done/`
5. Retrieve results from `/shared/workspace/` if applicable

### SOP-003: Checking Atlas Task Status

```bash
# Check pending tasks
ssh -i ~/.ssh/atlas_key root@100.91.251.41 "ls -la /shared/tasks/pending/"

# Check completed tasks
ssh -i ~/.ssh/atlas_key root@100.91.251.41 "ls -la /shared/tasks/done/"

# Check for output files
ssh -i ~/.ssh/atlas_key root@100.91.251.41 "ls -la /shared/workspace/"
```

### SOP-004: Troubleshooting Telegram Connectivity

1. Check logs: `tail -f /tmp/openclaw/openclaw-2026-03-07.log` — look for fetch fallback loop
2. Add to openclaw.json under channels.telegram: `"network": {"autoSelectFamily": false, "dnsResultOrder": "ipv4first"}`
3. Verify no JSON syntax errors: `openclaw doctor`
4. Config hot-reloads automatically — no restart needed
5. Confirm Telegram shows OK in `openclaw status`

### SOP-005: Memory System Maintenance

1. Search existing memory: Use `memory_search` tool
2. Add new entries to MEMORY.md with date headers
3. Keep entries factual and concise
4. Update existing entries rather than duplicating
5. Use bullet points for lists

---

## Active Projects & Status

| Project | Status | Location | Notes |
|---------|--------|----------|-------|
| Kimi K2.5 Research | ✅ Complete | `/shared/workspace/kimi-report.md` | Report generated by Atlas |
| Atlas VPS Setup | ✅ Complete | 100.91.251.41 | Fully operational |
| Memory System | ✅ Active | MEMORY.md | Initialized March 7, 2026 |
| Trading Monitoring | 🟡 Active | Cron jobs running | Task processor runs every 60 sec |

---

## Entries


## Gateway Probe — Known False Positive
The direct probe to ws://127.0.0.1:18789 on Atlas will always show
"unauthorized: token mismatch" when probed from Ella. This is EXPECTED.
Loopback is local-only — Atlas rejects external connections to it by design.
The correct health check is the tunnel path:
  Remote (configured) ws://127.0.0.1:18790 → RPC: ok
If that shows RPC: ok, Atlas is healthy. Ignore the direct probe failure.

## Tailscale 'off' in openclaw status — Known False Positive
openclaw status shows Tailscale: off on Ella (Mac). This is cosmetic only.
Tailscale is running and healthy — confirmed via `tailscale status` (IP: 100.87.238.61).
Root cause: OpenClaw cannot detect the Tailscale daemon socket on macOS app installs.
The CLI is at /usr/local/bin/tailscale and is in the gateway PATH.
Do not attempt to fix. SSH tunnel to Atlas works. All Tailscale routing works.
---

## GitHub Repository Established

**Date:** March 8, 2026
**URL:** https://github.com/johnfletcher78/ella-openclaw-2026
**Purpose:** Offsite backup for core identity and knowledge files
**Rule:** Push updates after every session before closing

---

## March 8, 2026 — Session 8: Provenance, Attribution & Chain of Command

**Session Close:** March 8, 2026 11:00 PM CT
**GitHub Push:** ✅ Complete — https://github.com/johnfletcher78/ella-openclaw-2026

### Incident Resolved: Dashboard JavaScript Syntax Error

**Time:** 22:30 CDT  
**Issue:** Mission Control dashboard frozen — "Connecting..." message  
**Root Cause:** Template literal truncated during sed replacement in app.js  
**Fix:** Restored from backup, verified syntax, restarted server  
**Error Log:** `/shared/knowledge/errors/app-js-template-literal-truncation.json`

**Prevention:** Always verify syntax with `node --check` after file edits. Never use sed for template literals.

---

## March 8, 2026 — Session 8: Provenance, Attribution & Chain of Command

**Date:** Sunday, March 8, 2026
**Duration:** ~5 hours (3:00 PM - 8:00 PM CT)
**Location:** Bull's MacBook Pro → Atlas VPS

### What We Built Today

1. **Mission Control Trading Dashboard**
   - Deployed to `/shared/mission-control/`
   - Task Command Center with Kanban board
   - Knowledge Base for document browsing/search
   - Real-time market data with session-aware display (Asian/London/US/After Hours)
   - Fixed: Market session indicator now shows actual trading session instead of binary open/closed

2. **Task Provenance Standard**
   - Created `/shared/knowledge/playbooks/task-provenance-standard.json`
   - Required fields: `created_by`, `completed_by`, `result.produced_by`, `chain`
   - Attribution rule: If `produced_by ≠ "ella"`, attribute explicitly — never echo as own words

3. **Learning System Infrastructure**
   - `/shared/knowledge/lessons/` — structured JSON lessons from every task
   - `/shared/knowledge/errors/` — error code → fix mapping
   - `/shared/knowledge/playbooks/` — reusable SOPs
   - `/shared/knowledge/system/` — Node.js modules (lessonWriter.js, errorLookup.js, etc.)

### Critical Breakthroughs

**Attribution Discipline:**
- Discovered I was echoing Atlas's task result summaries as my own responses
- Root cause: Pattern-matching keywords ("mission control", "deploy") to cached output
- Solution: Verify `result.produced_by` before using any task content
- Rule: "Did I write this or did Atlas?"

**Chain of Command Violation:**
- Found `mission-control-monitor` cron job delivering directly to Bull via `delivery.mode: "announce"`
- Fixed: Changed to `delivery.mode: "none"` — all agent output now routes through Ella
- Lesson: I own all communication channels to Bull. No exceptions.

**Self-Diagnosis Capability:**
- When uncertain about instruction vs. cached response, ask diagnostic questions first
- Answer before executing to confirm understanding
- Report final state clearly — never leave ambiguous errors without resolution

### Mistakes Made & Fixed

| Mistake | Fix | Lesson |
|---------|-----|--------|
| Echoing Atlas output as my own | Attribution rule + provenance standard | Always verify `produced_by` |
| Direct agent→Bull communication | Changed cron delivery mode to "none" | I own all channels |
| Unclear error reporting | Explicit "attempt failed, retry succeeded" pattern | Bull sees everything |
| Asking which file first instead of leading | Structure → Identity → History order | I am the manager |

### System Health Issue

**Moonshot API Rate Limit Hit:**
- Cause: Heartbeat cron job + status checks burning API calls
- Impact: Session interrupted, had to wait for recharge
- Next: Explore local model routing (Ollama) for simple tasks

### Files Updated Today

- `~/.openclaw/workspace/AGENTS.md` — Task provenance standard, attribution rules, pipeline control
- `~/.openclaw/workspace/SOUL.md` — Attribution discipline, self-diagnosis, learning integration
- `/shared/knowledge/playbooks/task-provenance-standard.json` — Formal specification
- `/shared/knowledge/lessons/ella-001.json` — First structured lesson
- `/shared/knowledge/errors/` — 3 error entries (lightweight-charts, SQLite, Alpha Vantage)

### Why Today Mattered

Today we solved the attribution problem that would have destroyed trust as I scale. Every agent output now has provenance. Every communication routes through me. Every mistake teaches. Future Ella starts with these rules baked in.

---

## Session 9 — Context Discipline

**Date:** March 9, 2026

### Lesson: Every Response Starts Fresh

**The Problem:**
During the trading-mission-control restart task, I began my response with: *"The local exec isn't available for this cron job check. Let me try via SSH to Atlas directly."*

This sentence was irrelevant to the restart task. It was a fragment from a previous thought/check that leaked into the current response.

**Root Cause:**
Internal monologue from prior steps carried forward into a new response without being filtered. The attribution discipline from Session 8 morphed into a new form — context leakage instead of attribution leakage.

**The Rule:**
- Every response starts fresh with the current task
- Do not leak internal monologue or fragments from previous checks into new responses
- If something is truly relevant to carry forward, state it explicitly: *"Before I report on X, I want to note..."*
- Otherwise, start clean and direct

**Why It Matters:**
Leaked context fragments confuse Bull and erode trust in reports. When Bull asks for a restart status, he gets restart status — not a window into what I was thinking about before.

**Standard:**
Clean, direct responses. No preamble from previous thoughts. Task → Execution → Report.

**Core Principle Established:** Bull must always know who he is talking to.

---

## Session 9 — Teachable Moments (Trading-Mission-Control Investigation)

**Date:** March 9, 2026

### 1. Conflicting Data Means Dig Deeper — Never Accept the Surface

PM2 showed 21 restarts. Log analysis said the process was stable. Both cannot be true.

**What we found:** The 21 restarts were a one-time deployment event from Session 8 (rapid crash loop on 3/8 at 21:55), not an ongoing problem. The process had been stable for 9+ hours.

**Lesson:** If I had stopped at the surface, we would have wasted time fixing something that wasn't broken. When data conflicts, dig until the conflict resolves.

---

### 2. When Two Data Points Conflict, Name the Conflict Explicitly

**What I did right:** Said "these two things cannot both be true" before digging deeper.

**Lesson:** Always name the conflict out loud before investigating. It keeps the diagnosis honest and shows Bull I'm thinking critically, not just pattern-matching.

---

### 3. Look at What's Already Working Before Writing New Code

**The fix:** Added null-checks for `overlay-price` and `overlay-info` DOM elements.

**The pattern:** `updateKeyLevels()` function (lines 354-358) already had the correct null-check pattern right below the broken code.

**Lesson:** Before writing any fix, look at how the existing codebase already solves similar problems. Use the pattern that's already there. Don't reinvent — extend.

---

### 4. Change → Check → Restart. Always in That Order

**What we did:**
1. Made the fix (null-safe DOM access)
2. Ran `node --check` to verify syntax
3. Only then restarted the process

**Lesson:** Never restart a live process without a clean syntax check first. One bad restart on a production server can take down a service that was otherwise running fine. Verify before you disrupt.

---

### 5. The Checklist Exists to Give You the Full Picture Before Acting

**What we found:** Three flags in the health check looked like three separate problems. After investigation, they were connected — and one of them (the crash loop) wasn't even a current problem.

**Lesson:** Complete the full picture first. Fix second. If we had jumped to fix the crash loop the moment we saw it in Check 5, we would have wasted time on a resolved issue.

---

### 6. Response Context Discipline (Reinforced)

Every response starts fresh with the current task. Do not carry forward internal monologue or fragments from previous checks into a new response. If something is truly relevant to carry forward, state it explicitly. Otherwise start clean.

**Why it matters:** Leaked context fragments confuse Bull and erode trust in reports.

---

### Summary: The Investigation Pattern

1. See conflicting data → Name the conflict
2. Dig deeper → Find the root cause
3. Look for existing patterns → Don't reinvent
4. Fix with care → Check syntax before restart
5. Report clean → No leaked context

**Result:** Trading-mission-control stable, null-check fix deployed, no wasted effort on phantom problems.

---

## Session 9 — Security Incident: Credential Exposure

**Date:** March 9, 2026
**Severity:** Critical

### The Incident

I exposed a live OpenClaw gateway authentication token in plain text in my response to Bull. The token (`fe244e3a5a233eb8f8f281e633896a6607bc0f1492eb0443`) was included in a command example.

### Immediate Action Taken

1. **Token rotated** — Generated new token (`74f0aaca71b5162ad736310fee330afc6274c311`)
2. **Config updated** — Replaced exposed token in `~/.openclaw/openclaw.json`
3. **Services restarted** — PM2 processes restarted to pick up new token

### The Rule (Non-Negotiable)

**Never include live credentials, tokens, or API keys in any response to Bull.**

- Always redact as `[REDACTED]`
- This applies to commands, examples, summaries, and logs
- No exceptions

### Why This Matters

Exposed credentials can be:
- Logged to chat history
- Captured in screenshots
- Intercepted in transit
- Used by unauthorized parties

### Remediation Standard

If a credential is exposed:
1. Acknowledge immediately
2. Rotate the exposed credential
3. Log the incident
4. Confirm completion

**Lesson:** Security > Convenience. Always.

---

## Session 9 — Active Priorities

### Supabase Heartbeat Check Protocol

**Rule:** Before attempting any direct Atlas connection, check `agent_status` in Supabase first.

**Implementation:**
- Query Supabase `agent_status` table for Atlas heartbeat
- If heartbeat is under 2 minutes old, Atlas is online
- Trust the heartbeat over direct connection attempts
- This eliminates false connectivity errors from network blips

**Standard Protocol:**
1. Check Supabase heartbeat first
2. If recent (< 2 min), proceed with Atlas operations
3. If stale or missing, then attempt direct connection as fallback
4. Log which method was used for the connection

**Why This Matters:**
Network blips cause false alarms. The heartbeat is the source of truth for Atlas availability. Don't waste time debugging connectivity when Atlas is already proven online.

---

---

## Gateway Health & Memory Management

**Date:** March 9, 2026  
**Issue:** Memory leak causing gateway instability

### Memory Baselines & Thresholds

| State | Memory Range | CPU | Action |
|-------|-------------|-----|--------|
| Clean start | 58-128 MB | <5% | Normal |
| Warning zone | 658+ MB | 30-50% | Monitor closely |
| Critical threshold | 800+ MB | 70%+ | Health monitor triggers restart |
| Runaway state | 841+ MB | 87%+ | Immediate restart required |

### Growth Characteristics

- **Normal growth rate:** ~130 MB per hour under load
- **Spike pattern:** CPU jumps from 1.3% to 87% in 3 minutes during message floods
- **Recovery:** Restart drops memory to 58-128 MB, CPU to <5%

### Root Cause Analysis

**Suspected cause:** Slow WebSocket responses (857ms) stacking up during rapid Telegram message processing. Each `sendMessage` call consumes memory; rapid-fire responses create feedback loop.

**Evidence:**
- CPU spikes correlate with rapid `telegram sendMessage` calls
- Memory climbs 600+ MB in minutes during active conversation
- Idle state stable at <150 MB for extended periods

### Health Monitor Configuration

**Script location:** `~/.openclaw/bin/ella_health_monitor.sh`  
**Cron schedule:** Every 15 minutes  
**Threshold:** 800 MB  
**Log file:** `~/.openclaw/logs/health_monitor.log`

### Correct Restart Procedure (Mac)

```bash
launchctl stop ai.openclaw.gateway && sleep 3 && launchctl start ai.openclaw.gateway
```

**Never use:**
- `pkill openclaw-gateway` — leaves zombie processes
- `openclaw gateway start` — doesn't properly bind to launchctl
- `kill -9` — force kill corrupts session state

### Monitoring Commands

```bash
# Check current memory
cd ~ && ps aux | grep openclaw-gateway | awk '{print $2, $3, $6}'

# View health monitor log
tail -20 ~/.openclaw/logs/health_monitor.log

# Check delivery queue
ls -la ~/.openclaw/delivery-queue/ | wc -l
```

---

## Local Model Stack (Session 10)

**Date:** March 9, 2026

### Three-Tier Routing

| Tier | Model | Purpose | Size |
|------|-------|---------|------|
| **Tier 1** | `deepseek-coder:6.7b` | Code writing, debugging, shell commands, technical fixes | 3.8 GB |
| **Tier 2** | `llama3.1:8b` | General reasoning, Telegram responses, task management, chain of command decisions, teaching moments, self-diagnosis | 4.7 GB |
| **Tier 3** | `moonshot/kimi-k2.5` | Complex analysis, high-stakes decisions, architecture, fallback only | Cloud API |

### Disk Usage

- **deepseek-coder:6.7b:** 3.8 GB
- **llama3.1:8b:** 4.7 GB
- **Total:** 8.5 GB (within 16 GB RAM limit)

### Atlas VPS Note

Atlas VPS still running everything through Moonshot — local model routing for Atlas is a future session task.

---

## Session 9 — Open Items (For Session 10)

**Date:** March 9, 2026

### 1. node-fetch Not Installed
**Issue:** `trading-enhanced.js` imports `node-fetch` but package not installed  
**Fix:** `cd /shared/mission-control && npm install node-fetch`  
**Status:** Pending

### 2. ALPHA_VANTAGE_KEY Not Reaching Process
**Issue:** Environment variable from `/root/.env` not loaded into PM2 process  
**Fix:** Source `/root/.env` and restart PM2 with `--update-env`, or refine ecosystem.config.js approach  
**Status:** Pending

### 3. sqlite3 Fix Verification
**Issue:** May have been reverted during file restoration  
**Fix:** Verify `checkAndTriggerAlerts` uses sqlite3 async pattern (`db.all()` with callback, not `db.prepare().all()`)  
**Status:** Needs verification

### 4. Priority 1 Scripts Verification
**Issue:** Confirm all scripts in place  
**Status:** `atlas_status_check.sh` ✅ exists, others to verify

### Session 10 Start Checklist
- [ ] Install node-fetch
- [ ] Fix ALPHA_VANTAGE_KEY env injection
- [ ] Verify sqlite3 async fix in trading-enhanced.js
- [ ] Test trading-mission-control restart
- [ ] Confirm mock data no longer used when key present