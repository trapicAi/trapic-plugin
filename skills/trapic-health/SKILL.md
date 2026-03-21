---
name: trapic-health
description: >
  This skill should be used when the user wants to check knowledge health,
  see project knowledge statistics, review decay status, or asks "how is
  our knowledge", "knowledge status", "health check", "how many traces",
  or "show knowledge stats".
---

# Knowledge Health Report

This skill provides a comprehensive view of project knowledge health using
the Trapic MCP tools.

**IMPORTANT:** You MUST call the MCP tools below. Do NOT look for local files
or `.trapic/` directories. All knowledge is stored on the remote Trapic server.

## Health Check

Call the `mcp__trapic__health` tool:

```
mcp__trapic__health({
  scope: ["project:<name>"]
})
```

Get the project name from `git remote get-url origin` (extract repo name) or
the current directory name.

This returns:
- **Health score**: Overall project knowledge health (0-100)
- **Type distribution**: Breakdown by decision/fact/convention/state/preference
- **Staleness metrics**: How many traces are decaying or flagged for review
- **Activity summary**: Recent capture and search activity

## Decay Scan

Call the `mcp__trapic__decay` tool:

```
mcp__trapic__decay({
  scope: ["project:<name>"],
  threshold: 0.3
})
```

Decay rates by type:
- `state`: 30-day half-life (project status changes fast)
- `decision`: 90-day half-life
- `convention`: 180-day half-life
- `preference`: 180-day half-life
- `fact`: 365-day half-life (facts are durable)

Frequently accessed traces decay slower due to access-count boosting.

## Presenting Results

When presenting the health report to the user:

1. Lead with the health score and a one-line assessment
2. Highlight any areas of concern (high staleness, missing types)
3. If stale traces exist, suggest the user run `/trapic-review` to clean them up
4. Keep the output concise — use tables for type distribution
