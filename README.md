# Trapic

[![Version](https://img.shields.io/badge/version-0.7.0-blue)](https://github.com/trapicAi/trapic-plugin) [![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE) [![MCP](https://img.shields.io/badge/MCP-compatible-purple)](https://modelcontextprotocol.io)

[English](./README.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

**Your team's shared brain — every AI tool, one knowledge base.**

---

## The problem

When your team uses AI tools, knowledge stays trapped in individual sessions. Sarah's AI doesn't know what James decided yesterday. Every conversation starts from zero.

## The solution

```
You: "What did the team decide about the database?"

→ AI calls trapic({action: "recall"})
→ Instant answer with full reasoning, source, and context
```

Trapic connects your AI tools to a shared knowledge base. Decisions, conventions, and discoveries are captured as your team works — and available to everyone's AI, automatically.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/trapicAi/trapic-plugin/main/scripts/install.sh | bash
```

Sign up at [trapic.ai](https://trapic.ai) to get your free API token.

---

## Works with

Claude Code, Cursor, Windsurf, GitHub Copilot, Gemini CLI — any tool that supports MCP.

---

## Key features

- **Auto-recall** — Your AI loads team knowledge at the start of every session. No briefing needed.
- **Smart decay** — Knowledge has half-lives. Stale decisions get flagged before they cause problems.
- **Conflict detection** — When a new decision contradicts an old one, Trapic catches it and keeps the record straight.
- **Cross-tool** — Same knowledge base whether you use Claude, Cursor, Copilot, or all of them.
- **Team sharing** — Private, team, or public visibility per piece of knowledge. You control what's shared.

---

## How it works

1. Someone on your team makes a decision — the AI captures it automatically
2. Next time anyone's AI starts a session, it loads the latest team context
3. Knowledge ages gracefully: quick status updates fade, architecture decisions persist
4. Contradictions are detected and resolved, so your team stays aligned

---

## Pricing

**Free during beta.** Get started at [trapic.ai](https://trapic.ai).

---

## Self-hosted

Want to run Trapic on your own infrastructure? Check out [trapic-core](https://github.com/trapicAi/trapic-core) for the self-hosted option.

---

## Links

- Website: [trapic.ai](https://trapic.ai)
- Documentation: [trapic.ai/docs](https://trapic.ai/docs)

## License

MIT
