---
name: trapic-review
description: >
  This skill should be used before creating a git commit to check staged
  changes against project conventions, or when recall briefing reports
  stale knowledge needing review. Triggers on "commit", "review conventions",
  "check before commit", "review stale", or "clean up old traces".
disable-model-invocation: true
---

# Pre-Commit Review & Stale Cleanup

This skill provides two workflows: checking staged code against recorded
conventions before committing, and reviewing stale knowledge flagged by
the decay system.

## Pre-Commit Convention Check

Run this before creating a git commit to catch convention violations.

**Step 1** — Get the staged diff:
```bash
git diff --staged
```

**Step 2** — Fetch project conventions:
```
trapic_search({
  types: ["convention", "decision", "preference"],
  scope: ["project:<name>"],
  limit: 20
})
```

**Step 3** — Compare the staged diff against each returned convention.
Look for:
- Naming pattern violations
- Architectural rule violations
- Style convention violations
- Preference contradictions

**Step 4** — Fix any violations before committing. If no violations found,
proceed with the commit.

## Stale Knowledge Review

Run this when recall briefing shows "STALE KNOWLEDGE (N traces need review)"
or when the user wants to clean up old knowledge.

**Step 1** — Scan for stale traces:
```
trapic_decay({
  scope: ["project:<name>"],
  threshold: 0.3
})
```

**Step 2** — For each stale trace, judge whether it is still valid by
checking current code state and recent decisions:

- Still valid: `trapic_review_stale({ trace_id: "<id>", action: "confirm" })`
- Outdated: `trapic_review_stale({ trace_id: "<id>", action: "deprecate" })`

**Step 3** — Report a summary of actions taken to the user:
- How many traces reviewed
- How many confirmed vs deprecated
- Any traces that need the user's judgment
