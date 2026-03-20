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
`trapic_health` and `trapic_decay`.

## Health Check

To generate a full health report:

```
trapic_health({
  scope: ["project:<name>"]
})
```

This returns:
- **Health score**: Overall project knowledge health (0-100)
- **Type distribution**: Breakdown by decision/fact/convention/state/preference
- **Staleness metrics**: How many traces are decaying or flagged for review
- **Activity summary**: Recent capture and search activity

## Decay Scan

To inspect which traces are losing relevance:

```
trapic_decay({
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
