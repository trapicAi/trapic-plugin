---
name: trapic-search
description: >
  This skill should be used when the user wants to search project knowledge,
  find past decisions, look up conventions, or ask questions like "what did
  we decide about X", "find traces about Y", "any conventions for Z",
  "search knowledge", or "what do we know about".
---

# Smart Search

Search project knowledge with topic-inferred filtering using the Trapic MCP tools.

**IMPORTANT:** You MUST call the `trapic-search` tool. Do NOT look for
local files or `.trapic/` directories. All knowledge is stored on the remote
Trapic server.

## Why Topic Inference Matters

Keyword search alone misses semantically related traces:
- User asks about "cache" but a trace says "Redis session storage"
- User asks about "styling" but a trace says "CSS custom properties"

Topic tags bridge this gap by grouping traces under problem domains.

## Search Process

**Step 1 — Extract keywords** from the user's request:
- "find me recent stuff about cache" -> keyword: `cache`
- "what did we decide about auth?" -> keyword: `auth`

**Step 2 — Infer 1-3 topic tags** describing the problem domain:
- `cache` -> `topic:caching`, `topic:performance`, `topic:infrastructure`
- `auth` -> `topic:authentication`, `topic:security`, `topic:api`
- `styling` -> `topic:styling`, `topic:theming`, `topic:css`

Tags describe the **area**, not the technology.

**Step 3 — Infer domain** from the topic area:

| Topic area | Domain |
|------------|--------|
| caching, infra | `domain:infrastructure` |
| auth, security | `domain:security` |
| styling, css, theming | `domain:design` |
| api, endpoints | `domain:api` |
| database, schema | `domain:database` |
| deploy, ci/cd | `domain:deployment` |
| testing, coverage | `domain:testing` |
| components, layout | `domain:ui` |
| framework, bundler | `domain:architecture` |

Domain values: `architecture`, `security`, `auth`, `api`, `database`,
`design`, `deployment`, `testing`, `ui`, `performance`, `infrastructure`,
`frontend`, `backend`, `strategy`

**Step 4 — Call `trapic-search`** with enriched parameters:
```
trapic-search({
  query: "<original keyword>",
  tags: ["topic:<inferred-1>", "topic:<inferred-2>", "topic:<inferred-3>"],
  scope: ["project:<name>", "domain:<inferred>"],
  limit: 10
})
```

`query` performs keyword substring matching. `tags` uses OR logic to catch
semantically related traces with different terminology. Together they cast
a wider net than either alone.

**Step 5 — If results are too few** (fewer than 3), broaden by removing
`domain` from scope and retry with only the project scope.

## Example

```
User: "what did we decide about caching?"
  |
  v
trapic-search({
  query: "cache",
  tags: ["topic:caching", "topic:performance", "topic:infrastructure"],
  scope: ["project:myapp", "domain:infrastructure"],
  types: ["decision", "convention"],
  limit: 10
})
  |
  v
Results:
  "Use Redis for session storage and caching"      <- keyword match
  "Switch to in-memory cache for lower latency"    <- topic:caching match
  "Cache TTL defaults: API 5min, sessions 24h"     <- topic:performance match
```

## Additional Filters

To narrow results, add optional parameters:
- `types: ["decision"]` — only decisions
- `types: ["convention"]` — only conventions
- `time_days: 7` — last 7 days only
- `status: "active"` — only active traces (default)
