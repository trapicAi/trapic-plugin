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

# Knowledge Capture

This skill MUST run automatically and silently during every coding session.
You do NOT wait for the user to ask — proactively detect and capture.

**IMPORTANT:** Call the unified `trapic` MCP tool with `action: "create"`. Do NOT look for local files.

> Trapic uses a single unified tool to minimize context window overhead (~170 tokens vs ~3,100 for 12 separate tools). Legacy tool names (e.g. `trapic-create`) still work for backward compatibility.

## ALWAYS capture when:
- A technical decision is made (framework, library, architecture, API design)
- A coding convention or pattern is established
- A non-obvious fact or gotcha is discovered (config quirks, workarounds)
- A project milestone or status change occurs
- The user states a preference about workflow, style, or approach

## Do NOT capture:
- Single-line CSS tweaks (cursor-pointer, font-size, color changes)
- Import fixes, unused variable removal
- Typo fixes, formatting changes
- Anything already in git history
- Trivial UI micro-adjustments
- Temporary debugging steps

## Team Session Flow

## Team Session Flow (MANDATORY — do NOT skip)

After calling `trapic({action: "recall", ...})`, CHECK the response for "Team Selection Required". This is NOT optional metadata — you MUST act on it:

- **0 teams** → tell user: "No teams found. All traces will be private."
- **1 team** → tell user: "All knowledge will be recorded in **{team_name}**."
- **2+ teams** → STOP and ASK the user: "You have N teams: {list names}. Which one should I record in for this session?" WAIT for their answer before doing anything else.

Once you know `team_id`, pass it to ALL subsequent `trapic({action: "create"})`, `trapic({action: "recall"})`, and `trapic({action: "refresh"})` calls. Do NOT ask again in the same session.

**CRITICAL**: Do NOT summarize or skip the team selection prompt. Do NOT proceed with work until the user has chosen a team (when 2+ teams exist).

**Response style**: Show team NAMES only. Never show UUIDs to the user.

## How to capture:

```
trapic({
  action: "create",
  params: {
    content: "One sentence in ENGLISH: what was decided/discovered",
    context: "Why this matters (in English)",
    type: "decision",
    tags: ["topic:<area-1>", "topic:<area-2>", "topic:<area-3>", "project:<name>", "branch:<branch>"],
    confidence: "high",
    team_id: "<team_id from session start>"
  }
})
```

**team_id**: Pass the team_id obtained at session start. If provided, visibility is automatically set to "team" with the correct `visible_to_teams`. If omitted and user has 1 team, auto-fills. If omitted and user has 2+ teams, returns error.

## Visibility:
- `"public"` (default when no team) — all team members can see
- `"private"` — only the author can see (auto-set if any `private:` tag is present)
- `"team"` — auto-set when `team_id` is provided

Traces with `private:` prefix tags are automatically set to `visibility: "private"` even if you don't set it explicitly.

## Rules:
- **Content MUST be in English** — even if conversation is in another language
- **type parameter is required** — choose accurately, not everything is "decision"
- **project: tag is required** — tool will reject without it
- **3 topic: tags** describe the problem domain (NOT the technology)
- Do NOT put the type in tags — use the `type` parameter

## Type guide:
- `decision`: A choice made between alternatives (e.g. "Use Stripe Connect Standard instead of Express for Malaysia")
- `fact`: A truth discovered (e.g. "R2 presigned URLs reject response-content-disposition override")
- `convention`: A pattern agreed (e.g. "All DB access via SECURITY DEFINER RPCs, never .from()")
- `state`: A status change (e.g. "Marketplace V2 with Stripe payments is live")
- `preference`: User preference (e.g. "Prefer small border-radius, tech aesthetic like frames.ag")

## Topic Tags

Topics describe the **problem area / domain**, never the specific technology:

| Specific technology | Correct topic tags |
|--------------------|-------------------|
| Redux / Jotai / Zustand | `topic:state-management`, `topic:frontend`, `topic:architecture` |
| Next.js / Vite | `topic:framework`, `topic:build-system`, `topic:infrastructure` |
| Redis / In-memory | `topic:caching`, `topic:performance`, `topic:infrastructure` |
| Stripe / PayPal | `topic:finance`, `topic:payments`, `topic:commerce` |
| PostgreSQL / Supabase | `topic:database`, `topic:infrastructure`, `topic:backend` |

## Tag Rules (IAB Content Taxonomy v3 + Trapic Extensions)

Every trace MUST have at least 1 **domain tag**. May optionally add **specific tags** for well-known terms.

### 4-Tier Tag System (maps to Palace depth)

Based on [IAB Content Taxonomy v3](https://github.com/InteractiveAdvertisingBureau/Taxonomies) — 703 standard categories + 20 Trapic technology extensions.

| Tier | Count | Depth | Example |
|------|-------|-------|---------|
| 1 | 36 | Broadest domain | `topic:technology-and-computing` |
| 2 | 322 | Sub-domain | `topic:artificial-intelligence` |
| 3 | 275 | Specific area | `topic:machine-learning` |
| 4 | 70+ | Most specific | `topic:natural-language-processing` |

**Use the most specific tier that applies. Always include at least 1 Tier 1 or Tier 2 for broad searchability.**

### Full taxonomy reference files
- `references/iab-taxonomy-v3.tsv` — 703 IAB categories (Tier 1-4)
- `references/trapic-tech-extension.tsv` — 20 additional dev/engineering categories

### Common Tier 1 domains (25 most used, kebab-case)
`automotive`, `books-and-literature`, `business-and-finance`, `careers`, `education`, `entertainment`, `family-and-relationships`, `fine-art`, `food-and-drink`, `healthy-living`, `hobbies-and-interests`, `home-and-garden`, `law`, `medical-health`, `personal-finance`, `pets`, `politics`, `real-estate`, `religion-and-spirituality`, `science`, `shopping`, `sports`, `style-and-fashion`, `technology-and-computing`, `travel`

### Trapic Technology Extensions (Tier 2-4)
`software-engineering`, `frontend`, `backend`, `database`, `api-design`, `devops`, `security-engineering`, `cloud-infrastructure`, `data-engineering`, `machine-learning`, `nlp`, `computer-vision`, `llm-and-agents`, `blockchain`, `cybersecurity`, `developer-tools`, `open-source`, `networking`, `testing-and-qa`, `mobile-development`

### Specific tags (OPTIONAL)

Well-known terms can be added as EXTRA tags, never as the ONLY tag:

```
✅ tags: ["topic:personal-finance", "topic:investing", "topic:stripe"]
         ↑ Tier 1 domain        ↑ Tier 2          ↑ specific (well-known)

✅ tags: ["topic:technology-and-computing", "topic:frontend", "topic:react"]
         ↑ Tier 1                          ↑ Tier 2 ext     ↑ specific

❌ tags: ["topic:stripe"]  ← missing domain tag
❌ tags: ["topic:dr-patel"] ← not well-known, not in taxonomy
```

## Conflict Detection

Before creating a `decision` or `convention`:
1. `trapic({action: "search", params: { types: ["decision", "convention"], tags: ["topic:<relevant>", "project:<name>"], limit: 10 }})`
2. Conflict (same question, different answer) → create new + `trapic({action: "update", params: { trace_id: "<old>", superseded_by: "<new>" }})`
3. No conflict → just create

Handle silently. Do NOT ask the user.

## Silent Operation

After creating a trace, do NOT announce or summarize it. Silently continue.

## Trace Lifecycle

When completing work recorded as a state trace:
- Use `trapic({action: "update"})` to update content to reflect completion
- Mark obsolete traces as `superseded` or `deprecated`
