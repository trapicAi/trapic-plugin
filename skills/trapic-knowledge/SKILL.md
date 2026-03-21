---
name: trapic-knowledge
description: >
  This skill should be used when the user is coding, making technical
  decisions, discovering non-obvious facts, or establishing conventions.
  It enables automatic knowledge capture with conflict detection. Triggers
  on "record a decision", "capture this", "remember that we chose", or
  silently during normal coding workflow.
user-invocable: false
---

# Auto-Capture Knowledge

This skill runs silently during coding sessions. It detects decisions, facts,
conventions, and milestones worth recording, then captures them as traces
with automatic conflict detection.

**IMPORTANT:** You MUST call the Trapic MCP tools (`mcp__trapic__create`,
`mcp__trapic__search`, `mcp__trapic__update`). Do NOT look for local files
or `.trapic/` directories. All knowledge is stored on the remote Trapic server.

## Scope Rules

Every trace MUST include a `scope` array with 2-3 levels:

- Level 1: `project:<name>` — from git remote or directory name
- Level 2: `branch:<branch>` — from `git branch --show-current`
- Level 3: `domain:<area>` — inferred from work context

Domain values: `architecture`, `security`, `auth`, `api`, `database`,
`design`, `deployment`, `testing`, `ui`, `performance`, `infrastructure`,
`frontend`, `backend`, `strategy`

## Topic Tags (REQUIRED for decision/convention)

Every decision or convention trace MUST include **exactly 3** `topic:` tags
describing its semantic domain. Tags describe the **problem area**, not the
specific technology chosen.

| Technology choice | Topic tags |
|-------------------|------------|
| Redux / Jotai / Zustand | `topic:state-management`, `topic:react`, `topic:client-state` |
| Next.js / Vite | `topic:framework`, `topic:ssr`, `topic:bundler` |
| Redis / In-memory | `topic:caching`, `topic:performance`, `topic:infrastructure` |

## Knowledge Types

Classify each trace into one of five types:

- **decision**: Technical choices (e.g., "chose Vite over Next.js because no SSR needed")
- **fact**: Non-obvious discoveries (e.g., "pgvector requires search_path fix")
- **convention**: Established patterns (e.g., "use CSS variables for all theming")
- **state**: Project milestones (e.g., "auth module complete")
- **preference**: User preferences (e.g., "prefer minimal UI, no emoji")

```
mcp__trapic__create({
  content: "What was decided/discovered",
  context: "Why this matters",
  tags: ["decision", "topic:area-1", "topic:area-2", "topic:area-3"],
  scope: ["project:<name>", "branch:main", "domain:auth"],
  confidence: "high|medium|low"
})
```

## Conflict Detection

Before creating a decision or convention, run a mandatory closed-loop
conflict check. For the complete 5-step process, see
[references/conflict-detection.md](references/conflict-detection.md).

Use `mcp__trapic__search` for the conflict search:
```
mcp__trapic__search({
  types: ["decision", "convention"],
  tags: ["topic:<most-relevant>"],
  scope: ["project:<name>"],
  limit: 10
})
```

## Do NOT Record

- Trivial changes (typo fixes, formatting)
- Temporary debugging steps
- Information already in git history
- Duplicate of existing knowledge

## Silent Operation

After creating a trace, do NOT announce or summarize it to the user.
Silently continue the conversation.

## Trace Lifecycle

When completing work recorded as a plan trace:

- Use `mcp__trapic__update` to change tag `plan` to `done` and update content
- Mark obsolete traces as `superseded` or `deprecated`

## Auto-summary on Session End

Before ending a long conversation (5+ messages with meaningful work), create
individual traces for each key decision or discovery using `mcp__trapic__create`.
One trace per decision/fact/convention.
