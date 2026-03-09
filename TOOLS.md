# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Atlas — VPS Orchestrator

**Name:** Atlas (the titan)
**Host:** srv1365311 (via Tailscale SSH)
**Tailscale IP:** 100.91.251.41
**User:** ubuntu
**OpenClaw Gateway:** ws://127.0.0.1:18789 (local loopback)
**Auth Token:** `d0db08c66ed546537d5461fb4e9d35e5590c173efa71d21b`
**Agent ID:** atlas

**Purpose:** Headless background worker. Carries the load when Mac sleeps — cron jobs, monitoring, sub-agents, trading watches.
**Access:** SSH tunnel or `exec ssh` from Mac
**Channels:** None (API only — no Telegram conflicts)

### Connecting
```bash
# SSH tunnel for local gateway access
ssh -L 19789:localhost:19789 ubuntu@100.85.198.42

# Or direct spawn via SSH
ssh ubuntu@100.85.198.42 'openclaw sessions spawn ...'
```

---

Add whatever helps you do your job. This is your cheat sheet.

# Atlas SSH Access

Ella can write files to Atlas directly via SSH:
- Host: 100.91.251.41 (or 100.91.251.41 via Tailscale)
- User: root
- Key: ~/.ssh/atlas_key
- Command: ssh -i ~/.ssh/atlas_key root@100.91.251.41 "<command>"

To write a task file to Atlas:
ssh -i ~/.ssh/atlas_key root@100.91.251.41 "cat > /shared/tasks/pending/<filename>.json" << 'ENDJSON'
{...json content...}
ENDJSON
