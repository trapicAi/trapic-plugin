# Trapic Plugin for Claude Code

AI long-term memory for coding assistants — auto-recall, knowledge capture with conflict detection, and smart decay.

## Install

### Option A: Plugin (recommended)

```bash
# 1. Add the marketplace
/plugin marketplace add nickjazz/trapic-plugin

# 2. Install the plugin
/plugin install trapic@nickjazz-trapic-plugin
```

Then set your token in `~/.claude/settings.json`:

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

Sign up at [trapic.ai](https://trapic.ai) to get your API token. Restart Claude Code after adding the token.

### Option B: Manual install (one-click script)

Run from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash
```

This sets up everything without using the plugin system:
- Adds MCP server config (`.mcp.json`)
- Creates SessionStart hook for auto-recall (`.claude/hooks/trapic-recall.sh`)
- Saves your token to `~/.claude/settings.json`

### Option C: Fully manual

**1. Add MCP server** — create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "trapic": {
      "type": "url",
      "url": "https://mcp.trapic.ai/mcp",
      "headers": {
        "Authorization": "Bearer ${TRAPIC_TOKEN}"
      }
    }
  }
}
```

**2. Add token** — edit `~/.claude/settings.json`:

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

**3. Add auto-recall hook** — create `.claude/hooks/trapic-recall.sh`:

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

Every session automatically loads project knowledge on startup via SessionStart hook — foundations, team updates, cross-branch activity. No manual action needed.

## How it works

1. **Session start** — Hook detects git project/branch, triggers `trapic-recall`
2. **During coding** — `trapic-knowledge` skill silently captures decisions with topic tags
3. **Before each decision** — Conflict detection searches by topic, supersedes old traces
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
│   ├── install.sh               # One-click manual install
│   ├── recall.sh                # Auto-detect project/branch + token check
│   └── setup.sh                 # Interactive setup guide
└── skills/
    ├── trapic-knowledge/        # Auto-capture + conflict detection
    ├── trapic-search/           # Smart search with topic inference
    ├── trapic-review/           # Pre-commit check + stale cleanup
    └── trapic-health/           # Health report + decay scan
```

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- A Trapic account with API token ([trapic.ai](https://trapic.ai))

## Links

- Website: [trapic.ai](https://trapic.ai)
- Documentation: [trapic.ai/docs](https://trapic.ai/docs)
- MCP Server: `https://mcp.trapic.ai/mcp`

## License

MIT
