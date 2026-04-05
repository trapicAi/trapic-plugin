# Trapic — AIコーディングアシスタントの長期記憶

[![Version](https://img.shields.io/badge/version-0.6.0-blue)](https://github.com/trapicAi/trapic-plugin) [![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE) [![MCP](https://img.shields.io/badge/MCP-compatible-purple)](https://modelcontextprotocol.io)

[English](./README.md) | [繁體中文](./README.zh-TW.md) | [日本語](./README.ja.md)

> **あなたのAIはセッションごとにすべてを忘れます。Trapicがそれを解決します。**
>
> 意思決定、コーディング規約、発見 — 自動キャプチャ、即座にリコール、インテリジェントに減衰。

## なぜ Trapic？

### 1. 自動リコール：すべてのセッションが記憶とともに始まる

AIアシスタントはセッション開始と同時にプロジェクト知識をロードします — チームの意思決定、コーディング規約、ブランチ横断のアクティビティ。手動のブリーフィングは不要。「コードベースを読み直します」も不要。即座にフルコンテキスト。

### 2. ナレッジキャプチャ + コンフリクト検出

技術的な意思決定（「ReduxからJotaiに切り替え」）をすると、Trapicがサイレントに記録します。以前の決定と矛盾する場合、古い方は自動的に「superseded（置換済み）」にマーク — 古い知識も矛盾もありません。

### 3. スマート減衰：知識が優雅にエイジングする

すべての知識の鮮度が同じではありません。プロジェクトステータス（`state`）は30日で減衰。アーキテクチャ決定（`decision`）は90日。命名規約（`convention`）は180日。古くなったトレースは自動的にフラグされ、レビューされ、クリーンアップされます。

---

## インストール

### オプション A：ワンクリックスクリプト（推奨）

最も安定したセットアップ方法。プロジェクトルートから実行：

```bash
curl -fsSL https://raw.githubusercontent.com/trapicAi/trapic-plugin/main/scripts/install.sh | bash
```

すべてを一度にセットアップ：
- MCPサーバー設定（`.mcp.json`）
- SessionStart hookで自動リコール
- CLAUDE.md指示の注入（hookが発火しなくてもAIが実行）
- トークンを `~/.claude/settings.json` に保存

### オプション B：プラグイン

```bash
/plugin marketplace add trapicAi/trapic-plugin
/plugin install trapic@trapicAi-trapic-plugin --scope user
```

> **Claude Codeのプラグインシステムについて：** マーケットプレイスはまだ若いです。Hookが発火しないことがあり、環境変数は手動設定が必要で、エラーメッセージは暗号的です（「Duplicate hooks file detected」— ありがとう、Anthropic）。プラグインインストールは動きますが、問題が発生したらオプションAが実戦テスト済みです。

インストール後、`~/.claude/settings.json` にトークンを設定：

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

[trapic.ai](https://trapic.ai) でサインアップしてAPIトークンを取得。設定後Claude Codeを再起動。

### オプション C：完全手動

**1. トークン設定** — `~/.claude/settings.json` を編集：

```json
{
  "env": {
    "TRAPIC_TOKEN": "tr_your_token_here"
  }
}
```

**2. MCPサーバー追加** — プロジェクトルートに `.mcp.json` を作成（`${TRAPIC_TOKEN}` はステップ1から自動的に読み込まれます）：

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

**3. 自動リコールhook（オプション）** — `.claude/hooks/trapic-recall.sh` を作成：

```bash
#!/bin/bash
PROJECT=$(git remote get-url origin 2>/dev/null | sed 's|.*/||;s|\.git$||')
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
[ -z "$PROJECT" ] && PROJECT=$(basename "$(pwd)")

cat <<EOF
Call trapic to load project knowledge before responding:
trapic({action: "recall", params: { context: "session start", scope: ["project:${PROJECT}", "branch:${BRANCH}"], project: "${PROJECT}" }})
EOF
```

`.claude/settings.json` にhookを登録：

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

セットアップ後Claude Codeを再起動。

### アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/trapicAi/trapic-plugin/main/scripts/uninstall.sh | bash
```

MCP設定、hook、CLAUDE.md指示を削除。トークンは選択的に削除可能。

## 取得できるもの

### 1つの統一MCPツール

Trapicは単一の統一ツールを使用してコンテキストウィンドウのオーバーヘッドを最小化します（~170トークン vs 12個別ツールの~3,100トークン）。

| アクション | 機能 |
|------------|------|
| `trapic({action: "recall"})` | セッション開始時にプロジェクト知識をロード |
| `trapic({action: "create"})` | 新しいナレッジトレースを作成 |
| `trapic({action: "search"})` | キーワード、タグ、scopeで検索 |
| `trapic({action: "update"})` | トレースのステータス、内容、タグを更新 |
| `trapic({action: "health"})` | プロジェクト知識の健全性レポート |
| `trapic({action: "decay"})` | 古い/減衰中の知識をスキャン |
| `trapic({action: "review-stale"})` | 古いトレースを確認または廃止 |

> レガシーツール名（例：`trapic-recall`）は後方互換性のため引き続き使用可能です。

### 4つのSkill（プラグインインストールのみ）

| Skill | トリガー | 機能 |
|-------|---------|------|
| **trapic-knowledge** | 自動（コーディング中） | 意思決定、規約、事実をサイレントキャプチャ（コンフリクト検出付き） |
| **trapic-search** | `/trapic-search` または「〜のトレースを探して」 | トピックタグ推論によるスマート検索 |
| **trapic-review** | `/trapic-review` | コミット前の規約チェック + 古い知識のクリーンアップ |
| **trapic-health** | `/trapic-health` または「ナレッジの状態」 | 健全性スコア、タイプ分布、減衰メトリクス |

## 動作フロー

1. **セッション開始** — Hook + CLAUDE.mdが `trapic({action: "recall"})` をトリガー、フルプロジェクトコンテキストをロード
2. **コーディング中** — 意思決定、規約、事実がトピックタグ付きでサイレントキャプチャ
3. **各決定前** — コンフリクト検出が同じトピックを検索、古いトレースを自動置換
4. **検索** — `trapic({action: "search"})` が曖昧なクエリからトピックタグを推論、セマンティックマッチング
5. **コミット前** — `/trapic-review` がstagedされた差分を規約と照合
6. **メンテナンス** — `/trapic-health` で健全性を表示、減衰システムが古い知識をフラグ

## 要件

- [Claude Code](https://claude.ai/claude-code) CLI（またはMCP対応の任意のAIツール）
- Trapicアカウント + APIトークン（[trapic.ai](https://trapic.ai)）

## リンク

- ウェブサイト：[trapic.ai](https://trapic.ai)
- ドキュメント：[trapic.ai/docs](https://trapic.ai/docs)
- MCPサーバー：`https://mcp.trapic.ai/mcp`

## ライセンス

MIT
