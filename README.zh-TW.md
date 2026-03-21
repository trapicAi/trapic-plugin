# Trapic — AI 程式助手的長期記憶

[![Version](https://img.shields.io/badge/version-0.6.0-blue)](https://github.com/nickjazz/trapic-plugin) [![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE) [![MCP](https://img.shields.io/badge/MCP-compatible-purple)](https://modelcontextprotocol.io)

[English](./README.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

> **你的 AI 每次對話都從零開始。Trapic 解決這個問題。**
>
> 決策、慣例、發現 — 自動捕捉、即時回憶、智慧衰減。

## 為什麼選 Trapic？

### 1. 自動回憶：每個 Session 都帶著記憶開始

AI 助手在 session 開始的瞬間載入專案知識 — 團隊決策、程式慣例、跨分支活動。不需要手動說明，不需要「讓我重新看一下 codebase」，直接擁有完整上下文。

### 2. 知識捕捉 + 衝突偵測

當你做出技術決策（「從 Redux 換成 Jotai」），Trapic 會靜默記錄。如果和之前的決策矛盾，舊的會自動被標記為取代 — 沒有過時知識，沒有矛盾。

### 3. 智慧衰減：知識會優雅地老化

不是所有知識的保鮮期都一樣。專案狀態（`state`）30 天衰減、架構決策（`decision`）90 天、命名慣例（`convention`）180 天。過期的 trace 會自動被標記、審查、清理。

---

## 安裝

### 方式 A：一鍵安裝腳本（推薦）

最穩定的安裝方式。在專案根目錄執行：

```bash
curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash
```

一次搞定所有設定：
- MCP server 設定（`.mcp.json`）
- SessionStart hook 自動回憶
- CLAUDE.md 指示注入（即使 hook 沒觸發，AI 也會照做）
- Token 存入 `~/.claude/settings.json`

### 方式 B：Plugin 安裝

```bash
/plugin marketplace add nickjazz/trapic-plugin
/plugin install trapic@nickjazz-trapic-plugin
```

> **關於 Claude Code 的 plugin 系統：** Marketplace 還很年輕。Hook 有時不觸發、環境變數要手動設定、錯誤訊息讓人摸不著頭緒（「Duplicate hooks file detected」— 謝了 Anthropic）。Plugin 安裝是能用的，但如果遇到問題，方式 A 是久經考驗的選擇。我們已經回報了不少 feedback，希望會改善。

安裝後在 `~/.claude/settings.json` 設定 token：

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

到 [trapic.ai](https://trapic.ai) 註冊取得 API token。設定後重啟 Claude Code。

### 方式 C：完全手動

**1. 設定 token** — 編輯 `~/.claude/settings.json`：

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

**2. 加入 MCP server** — 在專案根目錄建立 `.mcp.json`（`${TRAPIC_TOKEN}` 會自動從步驟 1 讀取）：

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

**3. 加入自動回憶 hook（選用）** — 建立 `.claude/hooks/trapic-recall.sh`：

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

然後在 `.claude/settings.json` 註冊 hook：

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

設定完成後重啟 Claude Code。

### 解除安裝

```bash
curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/uninstall.sh | bash
```

移除 MCP 設定、hook、CLAUDE.md 指示，token 可選擇是否移除。

## 你會得到什麼

### 7 個 MCP 工具

| 工具 | 功能 |
|------|------|
| `trapic-recall` | Session 開始時載入專案知識 |
| `trapic-create` | 建立新的知識 trace |
| `trapic-search` | 用關鍵字、標籤、scope 搜尋 |
| `trapic-update` | 更新 trace 狀態、內容、標籤 |
| `trapic-health` | 專案知識健康度報告 |
| `trapic-decay` | 掃描過期/衰減中的知識 |
| `trapic-review-stale` | 確認或廢棄過期 trace |

### 4 個 Skill（僅 plugin 安裝）

| Skill | 觸發方式 | 功能 |
|-------|---------|------|
| **trapic-knowledge** | 自動（寫程式時） | 靜默捕捉決策、慣例、事實，含衝突偵測 |
| **trapic-search** | `/trapic-search` 或「找 XX 的 trace」 | 語意推斷 topic tag 的智慧搜尋 |
| **trapic-review** | `/trapic-review` | commit 前慣例檢查 + 過期知識清理 |
| **trapic-health** | `/trapic-health` 或「知識庫狀態」 | 健康度、類型分佈、衰減指標 |

## 運作流程

1. **Session 開始** — Hook + CLAUDE.md 觸發 `trapic-recall`，載入完整專案上下文
2. **寫程式時** — 決策、慣例、事實被靜默捕捉，帶 topic tag
3. **每次決策前** — 衝突偵測搜尋相同 topic，自動取代過時 trace
4. **搜尋** — `trapic-search` 從模糊查詢推斷 topic tag，語意匹配
5. **commit 前** — `/trapic-review` 檢查 staged diff 是否違反慣例
6. **維護** — `/trapic-health` 顯示健康度，衰減系統標記過期知識

## 需求

- [Claude Code](https://claude.ai/claude-code) CLI（或任何支援 MCP 的 AI 工具）
- Trapic 帳號 + API token（[trapic.ai](https://trapic.ai)）

## 連結

- 網站：[trapic.ai](https://trapic.ai)
- 文件：[trapic.ai/docs](https://trapic.ai/docs)
- MCP Server：`https://mcp.trapic.ai/mcp`

## 授權

MIT
