---
name: trapic-search
description: >
  Use when the user wants to search project knowledge, find past decisions,
  look up conventions, or asks "what did we decide about X", "find traces
  about Y", "search knowledge", or "what do we know about".
---

# Smart Search

Search project knowledge using the unified `trapic` MCP tool with `action: "search"`.

**IMPORTANT:** Do NOT look for local files or `.trapic/` directories. All knowledge is on the remote Trapic server.

> Trapic uses a single unified tool to minimize context window overhead (~170 tokens vs ~3,100 for 12 separate tools). Legacy tool names (e.g. `trapic-search`) still work for backward compatibility.

## CRITICAL: Tags-First Search Strategy

**keyword search (query) is WEAK** — it only matches exact substrings. Searching "platform value" will NOT find a trace about "AI 協作的中文閱讀平台".

**Topic tags are the PRIMARY search mechanism.** Tags use OR logic and match by problem domain, bridging terminology gaps.

**ALWAYS include `tags` in every search call. NEVER search with only `query`.**

## Search Process — Think Like grep

Just like Claude Code uses `grep` with the right keywords (not raw natural language), Trapic search works best when you **infer structured tags + precise keywords** from the user's question.

**Step 1 — Infer topic tags + keyword** from the user's question:

| User asks | Inferred tags | Keyword |
|-----------|---------------|---------|
| "How do we handle offline?" | `topic:offline`, `topic:sync` | `offline` |
| "What's our auth approach?" | `topic:auth`, `topic:security` | — |
| "How do we track production issues?" | `topic:observability`, `topic:logging` | `monitoring` |
| "What did we decide about state management?" | `topic:state-management`, `topic:react` | — |
| "How do we make components accessible?" | `topic:accessibility` | — |
| "What's our API error format?" | `topic:api`, `topic:error-handling` | — |

**Step 2 — Call `trapic({action: "search"})`** with tags + optional keyword:
```
trapic({
  action: "search",
  params: {
    tags: ["topic:<inferred-1>", "topic:<inferred-2>", "project:<name>"],
    query: "<precise keyword if helpful>",
    limit: 10
  }
})
```

Tags and keywords work together — `project:`/`branch:` tags use AND logic (must match all), `topic:` tags use OR logic (any match). Keywords boost exact matches.

**Step 3 — If 0 results**, broaden: remove one topic tag, or try related tags.

**Step 4 — If still 0**, try keyword-only with a single technical term:
```
trapic({
  action: "search",
  params: {
    tags: ["project:<name>"],
    query: "<single technical keyword>",
    limit: 20
  }
})
```

**Step 5 — Need full content?** Use `trapic({action: "get"})` to read a specific trace:
```
trapic({action: "get", params: { trace_id: "<id from search results>" }})
```

## Examples

```
User: "How do we make the app work offline?"
  → AI infers: offline capability, sync
  → trapic({action: "search", params: { tags: ["topic:offline", "topic:sync", "project:mobile-app"], query: "offline" }})
  → Finds: "Offline data sync uses WatermelonDB" (tag match on topic:offline)

User: "What's our error handling convention?"
  → AI infers: error handling patterns
  → trapic({action: "search", params: { tags: ["topic:error-handling", "project:myapp"], types: ["convention"] }})
  → Finds: "API error responses follow RFC 7807" (tag match + type filter)

User: "What did we decide about Stripe?"
  → AI infers: payments, integration
  → trapic({action: "search", params: { tags: ["topic:payments", "project:ecommerce"], query: "Stripe" }})
  → Finds: "Chose Stripe over PayPal" (both tag and keyword match)
```

## Additional Filters

- `types: ["decision"]` — only decisions
- `types: ["convention"]` — only conventions
- `time_days: 7` — last 7 days only
- `status: "active"` — only active traces (default)
