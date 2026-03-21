---
name: trapic-search
description: >
  Use when the user wants to search project knowledge, find past decisions,
  look up conventions, or asks "what did we decide about X", "find traces
  about Y", "search knowledge", or "what do we know about".
---

# Smart Search

Search project knowledge using the `trapic-search` MCP tool.

**IMPORTANT:** Do NOT look for local files or `.trapic/` directories. All knowledge is on the remote Trapic server.

## CRITICAL: Tags-First Search Strategy

**keyword search (query) is WEAK** — it only matches exact substrings. Searching "platform value" will NOT find a trace about "AI 協作的中文閱讀平台".

**Topic tags are the PRIMARY search mechanism.** Tags use OR logic and match by problem domain, bridging terminology gaps.

**ALWAYS include `tags` in every search call. NEVER search with only `query`.**

## Search Process

**Step 1 — Infer 3 topic tags** from the user's question. Tags describe the **problem area**, not the technology:

| User asks about | Topic tags to use |
|----------------|-------------------|
| "platform value/direction" | `topic:product-direction`, `topic:platform-identity`, `topic:strategy` |
| "cache/performance" | `topic:caching`, `topic:performance`, `topic:infrastructure` |
| "auth/login" | `topic:authentication`, `topic:security`, `topic:api` |
| "styling/design" | `topic:styling`, `topic:theming`, `topic:visual-design` |
| "layout/responsive" | `topic:layout`, `topic:responsive-design`, `topic:ui` |
| "roadmap/features" | `topic:roadmap`, `topic:feature-planning`, `topic:project-scope` |
| "tech stack" | `topic:tech-stack`, `topic:infrastructure`, `topic:deployment` |

**Step 2 — Call `trapic-search`** with tags as primary filter:
```
trapic-search({
  tags: ["topic:<inferred-1>", "topic:<inferred-2>", "topic:<inferred-3>"],
  scope: ["project:<name>"],
  limit: 10
})
```

Do NOT include `query` in the first attempt. Tags alone will find the right traces.

**Step 3 — If 0 results**, broaden: remove one tag, or try related tags.

**Step 4 — If still 0**, fallback to `query` with a single short keyword:
```
trapic-search({
  query: "<single keyword>",
  scope: ["project:<name>"],
  limit: 20
})
```

**Step 5 — If still 0**, list all traces in scope (no filters):
```
trapic-search({
  scope: ["project:<name>"],
  limit: 50
})
```
Then scan results manually.

## Example

```
User: "what's our platform's value proposition?"
  |
  v
trapic-search({
  tags: ["topic:product-direction", "topic:platform-identity", "topic:strategy"],
  scope: ["project:myapp"],
  limit: 10
})
  |
  v
Results:
  "MM 定位為 AI 協作的中文閱讀平台"  <- topic:product-direction match
```

## Additional Filters

- `types: ["decision"]` — only decisions
- `types: ["convention"]` — only conventions
- `time_days: 7` — last 7 days only
- `status: "active"` — only active traces (default)
