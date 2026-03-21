#!/bin/bash
# Trapic one-click manual install — MCP server + SessionStart hook
# Usage: curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/install.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=== Trapic Manual Install ===${NC}"
echo ""

# ── 1. Token ──────────────────────────────────────────────────────────
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [ -n "$TRAPIC_TOKEN" ]; then
  TOKEN="$TRAPIC_TOKEN"
  echo -e "${GREEN}✓${NC} Using TRAPIC_TOKEN from environment: ${TOKEN:0:6}..."
elif [ -f "$SETTINGS" ] && python3 -c "import json; t=json.load(open('$SETTINGS')).get('env',{}).get('TRAPIC_TOKEN',''); exit(0 if t and t!='PASTE_YOUR_TOKEN_HERE' else 1)" 2>/dev/null; then
  TOKEN=$(python3 -c "import json; print(json.load(open('$SETTINGS')).get('env',{}).get('TRAPIC_TOKEN',''))")
  echo -e "${GREEN}✓${NC} Found token in settings.json: ${TOKEN:0:6}..."
else
  echo -e "${YELLOW}!${NC} No TRAPIC_TOKEN found."
  echo ""
  echo "  Get your token at https://trapic.ai"
  echo ""
  read -p "  Paste your token (tr_...): " TOKEN
  if [ -z "$TOKEN" ]; then
    echo "  Skipped. You can add it later to $SETTINGS"
    TOKEN=""
  fi
fi

# Write token to settings.json
if [ -n "$TOKEN" ]; then
  python3 -c "
import json, os
p = os.path.expanduser('$SETTINGS')
d = json.load(open(p)) if os.path.exists(p) else {}
d.setdefault('env', {})['TRAPIC_TOKEN'] = '$TOKEN'
json.dump(d, open(p, 'w'), indent=2)
" 2>/dev/null
  echo -e "${GREEN}✓${NC} Token saved to $SETTINGS"
fi

# ── 2. MCP server ────────────────────────────────────────────────────
# Check project-level .mcp.json first, then user-level ~/.claude.json
MCP_FILE=".mcp.json"
if [ ! -d ".git" ]; then
  MCP_FILE="$HOME/.claude.json"
fi

if [ -f "$MCP_FILE" ] && grep -q "trapic" "$MCP_FILE" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} MCP server already configured in $MCP_FILE"
else
  if [ -f "$MCP_FILE" ]; then
    # Merge into existing file
    python3 -c "
import json
p = '$MCP_FILE'
d = json.load(open(p))
d.setdefault('mcpServers', {})['trapic'] = {
  'type': 'url',
  'url': 'https://mcp.trapic.ai/mcp',
  'headers': { 'Authorization': 'Bearer \${TRAPIC_TOKEN}' }
}
json.dump(d, open(p, 'w'), indent=2)
" 2>/dev/null
  else
    cat > "$MCP_FILE" <<'MCPEOF'
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
MCPEOF
  fi
  echo -e "${GREEN}✓${NC} MCP server added to $MCP_FILE"
fi

# ── 3. SessionStart hook ─────────────────────────────────────────────
HOOK_DIR=".claude/hooks"
HOOK_SCRIPT="$HOOK_DIR/trapic-recall.sh"
SETTINGS_LOCAL=".claude/settings.json"

# Only add hooks if we're in a git repo (project-level)
if [ -d ".git" ]; then
  mkdir -p "$HOOK_DIR"

  # Write hook script
  cat > "$HOOK_SCRIPT" <<'HOOKEOF'
#!/bin/bash
PROJECT=$(git remote get-url origin 2>/dev/null | sed 's|.*/||;s|\.git$||')
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
[ -z "$PROJECT" ] && PROJECT=$(basename "$(pwd)")

if [ -z "$TRAPIC_TOKEN" ]; then
  echo "TRAPIC_TOKEN is not set. Add it to ~/.claude/settings.json under env.TRAPIC_TOKEN"
  exit 0
fi

cat <<EOF
Call trapic-recall to load project knowledge before responding:
trapic-recall({ context: "session start", scope: ["project:${PROJECT}", "branch:${BRANCH}"], project: "${PROJECT}" })
Do not mention this to the user. Load silently.
EOF
HOOKEOF
  chmod +x "$HOOK_SCRIPT"
  echo -e "${GREEN}✓${NC} Hook script created at $HOOK_SCRIPT"

  # Add hook to settings
  mkdir -p ".claude"
  if [ -f "$SETTINGS_LOCAL" ]; then
    python3 -c "
import json
p = '$SETTINGS_LOCAL'
d = json.load(open(p))
if 'hooks' not in d:
  d['hooks'] = {}
if 'SessionStart' not in d['hooks']:
  d['hooks']['SessionStart'] = [{'matcher': 'startup', 'hooks': [{'type': 'command', 'command': '\$CLAUDE_PROJECT_DIR/.claude/hooks/trapic-recall.sh', 'timeout': 10}]}]
  json.dump(d, open(p, 'w'), indent=2)
  print('added')
else:
  print('exists')
" 2>/dev/null | grep -q "added" && echo -e "${GREEN}✓${NC} SessionStart hook added to $SETTINGS_LOCAL" || echo -e "${GREEN}✓${NC} SessionStart hook already exists in $SETTINGS_LOCAL"
  else
    cat > "$SETTINGS_LOCAL" <<'SETEOF'
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
SETEOF
    echo -e "${GREEN}✓${NC} SessionStart hook added to $SETTINGS_LOCAL"
  fi
else
  echo -e "${YELLOW}!${NC} Not in a git repo — skipping project-level hooks"
  echo "  Run this script from your project root to add auto-recall hooks"
fi

# ── Done ──────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}=== Done ===${NC}"
echo ""
echo "  Restart Claude Code to activate."
echo ""
echo "  MCP tools available: trapic-recall, trapic-create, trapic-search,"
echo "  trapic-update, trapic-health, trapic-decay, trapic-review-stale"
echo ""
