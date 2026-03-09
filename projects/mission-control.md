# Mission Control — Project Specification

> **⚠️ AUTHORITY NOTICE:** Ella is the sole custodian of this file. Atlas has no direct access. All updates flow through Ella only.

---

## Vision

A unified command center for Bull's entire operation — trading, marketing, brewing, auto detail, and revenue opportunity hunting. One pane of glass to see everything: what's happening, who's doing what, what knowledge exists, and what opportunities are on the table.

---

## Core Modules

### 1. Knowledge Base (Library)
**Purpose:** Centralized repository for all research, documents, and intellectual property

**Features:**
- Hierarchical project folders (Trading, Marketing, Common John, Fresh & Clean, Revenue Ops)
- Document types: Research papers, presentations, SOPs, strategy docs, meeting notes
- Searchable by tag, date, project, document type
- Download/view interface for all stored files
- Auto-ingest from Atlas task outputs (`/shared/workspace/`)

**Storage:**
- Master index: Local (Ella's workspace)
- Document files: Atlas `/shared/knowledge/` (synced to Ella)
- Backup: Optional Supabase for cloud access

---

### 2. Task Command Center
**Purpose:** Real-time visibility into all work across all agents

**Features:**
- **Queue View:** Pending tasks waiting to be picked up
- **In Progress:** Active tasks with agent assignments
- **Completed:** Finished tasks with outputs/links
- **Kanban Board:** Drag-and-drop status management
- **Agent Workload:** Who's busy, who's available
- **Priority Matrix:** Eisenhower-style (Do/Schedule/Delegate/Eliminate)

**Data Source:**
- Atlas task queue (`/shared/tasks/pending/`, `/shared/tasks/done/`)
- Direct agent session tracking
- Cron job status

---

### 3. Trading Station (Phase 2)
**Purpose:** Live market monitoring and trade management

**Features:**
- Real-time YM/NQ futures data
- Price alerts and level notifications
- Open position tracking
- P&L dashboard
- Trading journal integration
- Strategy performance metrics

**Data Sources:**
- WebSocket feeds (Tradovate, Rithmic, or broker API)
- Trading journal database
- Prop firm account APIs (future)

---

### 4. Revenue Opportunity Pipeline
**Purpose:** Track and manage new business ideas and opportunities

**Features:**
- **Idea Capture:** Quick-add for new opportunities
- **Pipeline Stages:** Discovery → Validation → Planning → Execution
- **Assigned Agents:** Who's researching what
- **Status Dashboard:** Active opportunities, blocked items, completed deals
- **ROI Tracking:** Estimated vs actual returns

**Categories:**
- Trading strategy development
- Marketing service offerings
- Common John events/partnerships
- Fresh & Clean expansions
- New business ventures

---

### 5. Agent Activity Monitor
**Purpose:** See what Ella, Atlas, and all sub-agents are doing right now

**Features:**
- Live agent status (idle, working, error)
- Recent actions log
- Token/cost tracking per agent
- Session history
- Error alerts and retry status

---

### 6. Business Pillar Dashboard
**Purpose:** High-level health metrics for each business

**Sections:**
- **Trading:** Account balance, weekly P&L, win rate, current phase
- **Marketing:** Active clients, pipeline value, project status
- **Common John:** Event calendar, marketing campaigns, growth metrics
- **Fresh & Clean:** Operational metrics, marketing performance

---

## Technical Architecture

### Stack Options

**Option A: Local-First (Recommended Phase 1)**
- Frontend: Static HTML/JS or lightweight React
- Backend: Node.js + Express (on Atlas)
- Database: SQLite (Atlas) with file sync to Ella
- Real-time: Server-Sent Events or WebSocket
- File storage: Atlas `/shared/` directory

**Option B: Cloud-Connected (Phase 2)**
- Supabase for auth, database, and file storage
- Real-time subscriptions
- Access from anywhere
- Higher complexity, external dependency

### Data Flow

```
┌─────────────┐     SSH/Sync     ┌──────────────┐
│   Ella      │ ◄──────────────► │    Atlas     │
│  (Master)   │                  │  (Worker)    │
│  UI Access  │                  │ Task Queue   │
└─────────────┘                  │ File Storage │
                                 └──────────────┘
```

### API Integration Points

| System | Integration | Purpose |
|--------|-------------|---------|
| OpenClaw Gateway | WebSocket | Agent status, task events |
| Atlas Task Queue | File polling / SSH | Task CRUD operations |
| Trading Data | WebSocket/API | Live market feeds |
| Supabase (future) | REST/Realtime | Cloud sync, auth |

---

## UI Layout Concept

```
┌─────────────────────────────────────────────────────────────┐
│  MISSION CONTROL                              [User] [Alerts]│
├──────────┬──────────────────────────────────────────────────┤
│          │                                                  │
│  NAV     │           MAIN CONTENT AREA                      │
│          │                                                  │
│  📚 Lib   │   Context-aware dashboard based on selection    │
│  📋 Tasks │                                                  │
│  📈 Trade │   Default view: At-a-glance summary             │
│  💰 Rev   │   - Active tasks                                │
│  🤖 Agents│   - Recent completions                          │
│  🏢 Biz   │   - Alerts requiring attention                  │
│          │   - Quick stats per pillar                      │
│          │                                                  │
└──────────┴──────────────────────────────────────────────────┘
```

---

## Phase 1 MVP (Week 1-2)

1. **Static dashboard** with manual refresh
2. **Task queue viewer** (read-only from Atlas files)
3. **Knowledge base index** (file listing from `/shared/workspace/`)
4. **Simple agent status** (SSH check to Atlas)

## Phase 2 (Week 3-4)

1. Real-time updates via WebSocket
2. Task creation/delegation from UI
3. Document upload/download
4. Trading data integration (if API available)

## Phase 3 (Month 2)

1. Supabase integration for cloud access
2. Mobile-responsive design
3. Advanced analytics and reporting
4. Revenue pipeline full workflow

---

## Open Questions

1. **Trading data source:** What broker/prop firm API? (Tradovate, Rithmic, others?)
2. **Access pattern:** Local network only, or need remote access?
3. **Priority:** Which module delivers most value first?
4. **Tech preference:** Lightweight (vanilla JS) or full framework (React/Vue)?

---

## File Locations

| Component | Path |
|-----------|------|
| Project spec (this file) | `/Users/bullfletcher/.openclaw/workspace/projects/mission-control.md` |
| Knowledge base root | `ssh://atlas/shared/knowledge/` |
| Task queue | `ssh://atlas/shared/tasks/` |
| Workspace outputs | `ssh://atlas/shared/workspace/` |
| UI code (future) | `ssh://atlas/shared/mission-control/` |

---

## Related Resources

- **Research:** 
  - [builderz-labs/mission-control](https://github.com/builderz-labs/mission-control) — AI agent orchestration dashboard
  - [MeisnerDan/mission-control](https://github.com/MeisnerDan/mission-control) — Solo entrepreneur agent command center
- **Design Inspiration:** Trading terminal UIs on Dribbble, Figma community kits
- **Knowledge Management:** ResearchOps Community taxonomy standards

---

**Created:** March 8, 2026  
**Owner:** Ella (Strategic Orchestrator)  
**Status:** Specification complete — awaiting Bull's priorities for MVP build
