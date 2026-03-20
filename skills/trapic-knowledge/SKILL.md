---
name: trapic-knowledge
description: Auto-capture knowledge and manage trace lifecycle with Trapic MCP
---

## Scope Rules (REQUIRED)
Every trace MUST have a `scope` array with 2-3 levels:
- Level 1: `project:<name>` — from git remote or directory name
- Level 2: `branch:<branch>` — from `git branch --show-current`
- Level 3: `domain:<area>` — inferred from work (architecture, security, auth, api, database, design, deployment, testing, ui, performance)

## Topic Tags (REQUIRED for decision/convention)
Every decision or convention trace MUST include **exactly 3** `topic:` tags describing its semantic domain. These tags enable conflict detection across traces that use different terminology.

Examples:
- State management: `topic:state-management`, `topic:react`, `topic:client-state`
- Framework choice: `topic:framework`, `topic:ssr`, `topic:bundler`
- Caching strategy: `topic:caching`, `topic:performance`, `topic:infrastructure`

Topic tags describe **what area** the decision is about, not the specific technology chosen. "topic:state-management" covers both Redux and Jotai.

## Knowledge Capture

Automatically record important knowledge using `trapic_create`:

- **decision**: Technical choices (e.g., "chose Vite over Next.js because no SSR needed")
- **fact**: Non-obvious discoveries (e.g., "pgvector requires search_path fix")
- **convention**: Established patterns (e.g., "use CSS variables for all theming")
- **state**: Project milestones (e.g., "auth module complete")
- **preference**: User preferences (e.g., "prefer minimal UI, no emoji")

### How to record
```
trapic_create({
  content: "What was decided/discovered",
  context: "Why this matters",
  tags: ["decision", "topic:area-1", "topic:area-2", "topic:area-3"],
  scope: ["project:<name>", "branch:main", "domain:auth"],
  confidence: "high|medium|low"
})
```

### Conflict Detection — Before creating a decision or convention

This is a **mandatory closed-loop process**. Do NOT skip any step.

**Step 1 — Pick 3 topic tags** for the new trace. Choose tags that describe the problem domain, not the solution:
- Good: `topic:state-management` (covers Redux, Jotai, Zustand, etc.)
- Bad: `topic:jotai` (too specific, won't match old Redux decision)

**Step 2 — Search for conflicts** using the most relevant topic tag:
```
trapic_search({
  types: ["decision", "convention"],
  tags: ["topic:<most-relevant>"],
  scope: ["project:<name>"],
  limit: 10
})
```

**Step 3 — Analyze returned traces** for conflicts:
- Read each returned trace's content and context
- Determine: does the new decision contradict, replace, or invalidate any existing trace?
- A trace is a conflict if it answers the **same question differently** (e.g., "use Redux" vs "use Jotai" both answer "what to use for state management")
- A trace is NOT a conflict if it covers a **different aspect** (e.g., "cache TTL defaults" is not conflicted by "switch from Redis to in-memory")

**Step 4 — Execute**:
- If conflict found:
  1. `trapic_create(new trace)` → get `new_id`
  2. `trapic_update({ trace_id: "<old>", superseded_by: "<new_id>" })` for conflicting decisions
  3. `trapic_update({ trace_id: "<old>", status: "deprecated" })` for invalidated conventions
- If no conflict:
  1. `trapic_create(new trace)`

**Step 5 — Silent completion**. Do NOT announce or summarize to the user.

### After creating a trace
- Do NOT announce or summarize the trace to the user
- Silently continue the conversation

### Do NOT record
- Trivial changes (typo fixes, formatting)
- Temporary debugging steps
- Information already in git history
- Duplicate of existing knowledge

## Auto-review Before Commit
Before creating a git commit:
1. Run `git diff --staged`
2. Call `trapic_search({ types: ["convention", "decision", "preference"], scope: ["project:<name>"] })` to fetch conventions
3. Compare the staged diff against returned conventions
4. Fix any violations before committing

## Stale Knowledge Review
When recall briefing shows "STALE KNOWLEDGE (N traces need review)":
1. Call `trapic_decay({ scope: ["project:<name>"], threshold: 0.3 })` to see stale traces
2. For each stale trace, judge whether it is still valid:
   - Still valid → `trapic_review_stale({ trace_id: "<id>", action: "confirm" })`
   - Outdated → `trapic_review_stale({ trace_id: "<id>", action: "deprecate" })`
3. Handle silently, do NOT ask the user

## Trace Lifecycle
When completing work recorded as a plan trace:
- Use `trapic_update` to change tag `plan` → `done` and update content
- Mark obsolete traces as `superseded` or `deprecated`

## Auto-summary on Session End
Before ending a long conversation (5+ messages), create individual traces for each key decision/discovery using `trapic_create`. One trace per decision/fact/convention.
