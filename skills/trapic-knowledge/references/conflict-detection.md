# Conflict Detection — Closed-Loop Process

Before creating any decision or convention trace, this mandatory process
prevents contradictory knowledge from coexisting in the knowledge base.

**IMPORTANT:** Use Trapic MCP tools (`trapic-search`, `trapic-create`,
`trapic-update`) for all operations.

## 5-Step Flow

```
Client AI determines a decision/convention is worth recording
  |
  +-- Step 1: Pick 3 topic tags
  |     Describe the problem domain, not the solution.
  |     Good: topic:state-management (covers Redux, Jotai, Zustand)
  |     Bad:  topic:jotai (too specific, won't match old Redux trace)
  |
  +-- Step 2: Search for conflicts using the most relevant topic tag
  |     trapic-search({
  |       types: ["decision", "convention"],
  |       tags: ["topic:<most-relevant>"],
  |       scope: ["project:<name>"],
  |       limit: 10
  |     })
  |     Returns 2-5 precisely related traces, not the entire history.
  |
  +-- Step 3: Analyze returned traces for conflicts
  |     Conflict = same question, different answer
  |       "Use Redux" vs "Use Jotai" -> both answer "what for state management" -> conflict
  |     Not a conflict = different aspect
  |       "Cache TTL defaults" vs "switch from Redis" -> different questions -> no conflict
  |
  +-- Step 4: Execute
  |     If conflict found:
  |       1. trapic-create(new trace) -> get new_id
  |       2. trapic-update({ trace_id: "<old>", superseded_by: "<new_id>" })
  |          for conflicting decisions
  |       3. trapic-update({ trace_id: "<old>", status: "deprecated" })
  |          for invalidated conventions
  |     If no conflict:
  |       1. trapic-create(new trace)
  |
  +-- Step 5: Silent completion
        Do NOT announce or summarize to the user.
```

## Scenario Examples

### Scenario 1: Redux to Jotai

Search `tags: ["topic:state-management"]` returns:
```
[decision] Use Redux Toolkit for global state management
[convention] All Redux slices must use createSlice pattern
```

Analysis:
- The decision is superseded by the new Jotai decision
- The convention is deprecated (createSlice no longer applies)

### Scenario 2: Next.js to Modern.js

Search `tags: ["topic:framework", "topic:ssr"]` returns:
```
[decision] Use Next.js App Router for SSR
[convention] Use Next.js API routes for backend
[decision] Deploy on Vercel for preview deployments
```

Analysis:
- Next.js SSR decision: superseded
- API routes convention: deprecated
- Vercel deployment: not a conflict (deployment strategy != framework choice)

### Scenario 3: Redis to In-memory Cache

Search `tags: ["topic:caching", "topic:performance"]` returns:
```
[decision] Use Redis for session storage and caching
[convention] Cache keys follow pattern {service}:{entity}:{id}
[decision] Cache TTL defaults: API 5min, sessions 24h
```

Analysis:
- Redis decision: superseded
- Key naming convention: not a conflict (naming is backend-agnostic)
- TTL defaults: not a conflict (TTL strategy is cache-backend-agnostic)
