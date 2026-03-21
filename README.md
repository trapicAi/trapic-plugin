# Trapic — Long-term Memory for AI Coding Assistants

[![Version](https://img.shields.io/badge/version-0.6.0-blue)](https://github.com/nickjazz/trapic-plugin) [![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE) [![MCP](https://img.shields.io/badge/MCP-compatible-purple)](https://modelcontextprotocol.io)

[English](./README.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

> **Your AI forgets everything between sessions. Trapic fixes that.**
>
> Decisions, conventions, and discoveries — captured automatically, recalled instantly, decayed intelligently.

## Why Trapic?

### 1. Auto-Recall: Every Session Starts Smart

Your AI assistant loads project knowledge the moment a session begins — team decisions, coding conventions, cross-branch activity. No manual briefing. No "let me re-read the codebase." Just instant context.

### 2. Knowledge Capture with Conflict Detection

When you make a technical decision ("switch from Redux to Jotai"), Trapic silently records it. If it contradicts an earlier decision, the old one is automatically superseded — no stale knowledge, no contradictions.

### 3. Smart Decay: Knowledge That Ages Gracefully

Not all knowledge ages the same. A project status update (`state`) decays in 30 days. An architectural decision (`decision`) lasts 90. A naming convention (`convention`) holds for 180. Stale traces are flagged, reviewed, and cleaned up — automatically.

---

## Install

### Option A: One-Click Script (recommended)

The most reliable setup. Run from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash
```

This sets up everything in one shot:
- MCP server config (`.mcp.json`)
- SessionStart hook for auto-recall
- CLAUDE.md instructions (so your AI knows to use Trapic even if hooks don't fire)
- Token saved to `~/.claude/settings.json`

### Option B: Plugin

```bash
/plugin marketplace add nickjazz/trapic-plugin
/plugin install trapic@nickjazz-trapic-plugin
```

> **A note on Claude Code's plugin system:** The marketplace is still young. Hooks sometimes don't fire, env vars require manual setup, and error messages can be cryptic ("Duplicate hooks file detected" — thanks for that one, Anthropic). The plugin install works, but if you hit issues, Option A is battle-tested. We've filed our share of feedback. Hopefully things improve.

Then set your token in `~/.claude/settings.json`:

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

Sign up at [trapic.ai](https://trapic.ai) to get your API token. Restart Claude Code after adding the token.

### Option C: Fully manual

**1. Set your token** — edit `~/.claude/settings.json`:

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

**2. Add MCP server** — create `.mcp.json` in your project root (the `${TRAPIC_TOKEN}` is auto-filled from step 1):

```json
{
  "mcpServers": {
    "trapic": {
      "type": "http",
      "url": "https://mcp.trapic.ai/mcp",
      "headers": {
        "Authorization": "Bearer ${TRAPIC_TOKEN}"
      }
    }
  }
}
```

**3. Add auto-recall hook (optional)** — create `.claude/hooks/trapic-recall.sh`:

```bash
#!/bin/bash
PROJECT=$(git remote get-url origin 2>/dev/null | sed 's|.*/||;s|\.git$||')
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
[ -z "$PROJECT" ] && PROJECT=$(basename "$(pwd)")

cat <<EOF
Call trapic-recall to load project knowledge before responding:
trapic-recall({ context: "session start", scope: ["project:${PROJECT}", "branch:${BRANCH}"], project: "${PROJECT}" })
EOF
```

Then register the hook in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/trapic-recall.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Restart Claude Code after setup.

### Update

```
/plugin marketplace update nickjazz-trapic-plugin
```

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/uninstall.sh | bash
```

Removes MCP config, hooks, CLAUDE.md instructions, and optionally your token.

## What you get

### 7 MCP Tools

| Tool | What it does |
|------|-------------|
| `trapic-recall` | Load project knowledge at session start |
| `trapic-create` | Create a new knowledge trace |
| `trapic-search` | Search traces by keyword, tags, scope |
| `trapic-update` | Update trace status, content, or tags |
| `trapic-health` | Project knowledge health report |
| `trapic-decay` | Scan for stale/decaying knowledge |
| `trapic-review-stale` | Confirm or deprecate stale traces |

### 4 Skills (plugin install only)

| Skill | Trigger | What it does |
|-------|---------|--------------|
| **trapic-knowledge** | Auto (while coding) | Silently captures decisions, conventions, and facts with conflict detection |
| **trapic-search** | `/trapic-search` or "find traces about..." | Smart search with topic-inferred filtering |
| **trapic-review** | `/trapic-review` | Pre-commit convention check + stale knowledge cleanup |
| **trapic-health** | `/trapic-health` or "knowledge status" | Health score, type distribution, decay metrics |

### Auto-recall

Every session automatically loads project knowledge on startup — foundations, team updates, cross-branch activity. No manual action needed.

### Auto-capture (Stop hook)

After each AI response, a subagent reviews the conversation and silently captures any decisions, conventions, or discoveries using `trapic-create`. This is more reliable than asking the main AI to "always capture while coding" — the subagent runs independently after the main task is done.

## How it works

1. **Session start** — Hook + CLAUDE.md triggers `trapic-recall`, loads full project context
2. **After each response** — Stop hook spawns a subagent to capture decisions/conventions/facts
3. **Before each decision** — Conflict detection searches by topic, supersedes outdated traces
4. **Search** — `trapic-search` infers topic tags from vague queries for semantic matching
5. **Before commit** — `/trapic-review` checks staged diff against project conventions
6. **Maintenance** — `/trapic-health` shows knowledge health, decay flags stale traces

## Plugin Structure

```
trapic-plugin/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace listing
├── .mcp.json                    # MCP server connection
├── hooks/
│   └── hooks.json               # SessionStart auto-recall
├── scripts/
│   ├── install.sh               # One-click install (MCP + hooks + CLAUDE.md)
│   ├── uninstall.sh             # Clean removal
│   ├── recall.sh                # Auto-detect project/branch + token check
│   └── setup.sh                 # Interactive setup guide
└── skills/
    ├── trapic-knowledge/        # Auto-capture + conflict detection
    ├── trapic-search/           # Smart search with topic inference
    ├── trapic-review/           # Pre-commit check + stale cleanup
    └── trapic-health/           # Health report + decay scan
```

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI (or any MCP-compatible AI tool)
- A Trapic account with API token ([trapic.ai](https://trapic.ai))

## Links

- Website: [trapic.ai](https://trapic.ai)
- Documentation: [trapic.ai/docs](https://trapic.ai/docs)
- MCP Server: `https://mcp.trapic.ai/mcp`

## License

MIT
