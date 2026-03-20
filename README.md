# Trapic Plugin for Claude Code

AI long-term memory for coding assistants — auto-recall, knowledge capture with conflict detection, and smart decay.

## What it does

- **Auto-recall**: Every new session automatically loads project knowledge — foundations, team updates, cross-branch activity
- **Auto-capture**: Decisions and conventions are silently recorded with topic tags as you work
- **Conflict detection**: Topic-based search catches contradictions even when technology names differ (e.g., Redux vs Jotai)
- **Smart decay**: Stale knowledge is flagged and reviewed automatically — your knowledge base stays fresh

## Quick Start

### 1. Get a Trapic token

Sign up at [trapic.ai](https://trapic.ai) and create an API token in your dashboard.

### 2. Set your token

```bash
export TRAPIC_TOKEN=tr_your_token_here
```

### 3. Install the plugin

```bash
# Test locally
claude --plugin-dir /path/to/trapic-plugin

# Or install permanently
claude plugin install trapic --scope user
```

## How it works

1. **Session start** → Hook runs `recall.sh` → detects git project/branch
2. **Claude calls `trapic_recall`** → loads structured briefing from Trapic MCP server
3. **During conversation** → SKILL.md rules guide auto-capture of decisions/conventions
4. **Before each decision** → conflict detection searches by topic tags, supersedes old traces
5. **Background** → daily decay scan flags stale knowledge for AI review

## Plugin Structure

```
trapic-plugin/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest
├── .mcp.json              # MCP server connection (hosted at mcp.trapic.ai)
├── hooks/
│   └── hooks.json         # SessionStart hook config
├── scripts/
│   └── recall.sh          # Auto-detect project/branch, trigger recall
└── skills/
    └── trapic-knowledge/
        └── SKILL.md        # Auto-capture rules, conflict detection, decay review
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
