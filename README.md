# Trapic Plugin for Claude Code

AI long-term memory for coding assistants — auto-recall, knowledge capture with conflict detection, and smart decay.

## Install

```bash
# 1. Add the marketplace
/plugin marketplace add nickjazz/trapic-plugin

# 2. Install the plugin
/plugin install trapic@nickjazz-trapic-plugin
```

Then set your token:

```bash
export TRAPIC_TOKEN=tr_your_token_here
```

Sign up at [trapic.ai](https://trapic.ai) to get your API token.

### Update

```
/plugin marketplace update nickjazz-trapic-plugin
```

## What you get

### 4 Skills

| Skill | Trigger | What it does |
|-------|---------|--------------|
| **trapic-knowledge** | Auto (while coding) | Silently captures decisions, conventions, and facts with conflict detection |
| **trapic-search** | `/trapic-search` or "find traces about..." | Smart search with topic-inferred filtering — expands vague queries semantically |
| **trapic-review** | `/trapic-review` | Pre-commit convention check + stale knowledge cleanup |
| **trapic-health** | `/trapic-health` or "knowledge status" | Health score, type distribution, decay metrics |

### Auto-recall

The `trapic-knowledge` skill automatically calls `trapic_recall` at session start — loads foundations, team updates, cross-branch activity. No hook needed, no manual action.

### MCP Server

Connects to `mcp.trapic.ai` with 7 tools: `recall`, `create`, `search`, `update`, `decay`, `review_stale`, `health`.

## How it works

1. **Session start** — `trapic-knowledge` skill detects git project/branch, triggers `trapic_recall`
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
└── skills/
    ├── trapic-knowledge/        # Auto-capture + conflict detection
    │   ├── SKILL.md
    │   └── references/
    │       └── conflict-detection.md
    ├── trapic-search/           # Smart search with topic inference
    │   └── SKILL.md
    ├── trapic-review/           # Pre-commit check + stale cleanup
    │   └── SKILL.md
    └── trapic-health/           # Health report + decay scan
        └── SKILL.md
```

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- A Trapic account with API token (`TRAPIC_TOKEN` env var)

## Links

- Website: [trapic.ai](https://trapic.ai)
- Documentation: [trapic.ai/docs](https://trapic.ai/docs)
- MCP Server: `https://mcp.trapic.ai/mcp`

## License

MIT
