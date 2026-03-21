#!/bin/bash
# Trapic uninstall — remove MCP server, hooks, and CLAUDE.md instructions
# Usage: curl -fsSL https://raw.githubusercontent.com/nickjazz/trapic-plugin/main/scripts/uninstall.sh | bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=== Trapic Uninstall ===${NC}"
echo ""

# ── 1. Remove MCP server from .mcp.json ──────────────────────────────
MCP_FILE=".mcp.json"
if [ ! -f "$MCP_FILE" ]; then
  MCP_FILE="$HOME/.claude.json"
fi

if [ -f "$MCP_FILE" ] && grep -q "trapic" "$MCP_FILE" 2>/dev/null; then
  python3 -c "
import json
p = '$MCP_FILE'
d = json.load(open(p))
if 'mcpServers' in d and 'trapic' in d['mcpServers']:
  del d['mcpServers']['trapic']
  if not d['mcpServers']:
    del d['mcpServers']
  json.dump(d, open(p, 'w'), indent=2)
  print('removed')
else:
  print('not_found')
" 2>/dev/null | grep -q "removed" && echo -e "${GREEN}✓${NC} Removed trapic from $MCP_FILE" || echo -e "${YELLOW}!${NC} trapic not found in $MCP_FILE"
else
  echo -e "${YELLOW}!${NC} No MCP config with trapic found"
fi

# ── 2. Remove SessionStart hook ──────────────────────────────────────
HOOK_SCRIPT=".claude/hooks/trapic-recall.sh"
if [ -f "$HOOK_SCRIPT" ]; then
  rm "$HOOK_SCRIPT"
  echo -e "${GREEN}✓${NC} Removed $HOOK_SCRIPT"
else
  echo -e "${YELLOW}!${NC} No hook script found at $HOOK_SCRIPT"
fi

# Remove hook from settings
SETTINGS_LOCAL=".claude/settings.json"
if [ -f "$SETTINGS_LOCAL" ] && grep -q "trapic-recall" "$SETTINGS_LOCAL" 2>/dev/null; then
  python3 -c "
import json
p = '$SETTINGS_LOCAL'
d = json.load(open(p))
if 'hooks' in d and 'SessionStart' in d['hooks']:
  d['hooks']['SessionStart'] = [
    entry for entry in d['hooks']['SessionStart']
    if not any('trapic' in h.get('command','') for h in entry.get('hooks',[]))
  ]
  if not d['hooks']['SessionStart']:
    del d['hooks']['SessionStart']
  if not d['hooks']:
    del d['hooks']
  json.dump(d, open(p, 'w'), indent=2)
  print('removed')
else:
  print('not_found')
" 2>/dev/null | grep -q "removed" && echo -e "${GREEN}✓${NC} Removed hook from $SETTINGS_LOCAL" || echo -e "${YELLOW}!${NC} No trapic hook in $SETTINGS_LOCAL"
else
  echo -e "${YELLOW}!${NC} No trapic hook in settings"
fi

# ── 3. Remove Trapic section from CLAUDE.md ──────────────────────────
if [ -f "CLAUDE.md" ] && grep -q "trapic-recall" "CLAUDE.md" 2>/dev/null; then
  python3 -c "
import re
with open('CLAUDE.md', 'r') as f:
    content = f.read()
# Remove the Trapic sections (from '## Trapic —' to next '## ' or end of file)
cleaned = re.sub(r'\n## Trapic — [^\n]*\n(?:(?!## ).)*', '', content, flags=re.DOTALL)
# Remove trailing whitespace/newlines
cleaned = cleaned.rstrip() + '\n'
with open('CLAUDE.md', 'w') as f:
    f.write(cleaned)
print('removed')
" 2>/dev/null | grep -q "removed" && echo -e "${GREEN}✓${NC} Removed Trapic sections from CLAUDE.md" || echo -e "${YELLOW}!${NC} Could not clean CLAUDE.md — remove manually"
else
  echo -e "${YELLOW}!${NC} No Trapic instructions in CLAUDE.md"
fi

# ── 4. Remove skills ─────────────────────────────────────────────────
REMOVED_SKILLS=0
for SKILL_NAME in trapic-search trapic-health trapic-review; do
  SKILL_DIR=".claude/skills/$SKILL_NAME"
  if [ -d "$SKILL_DIR" ]; then
    rm -rf "$SKILL_DIR"
    REMOVED_SKILLS=$((REMOVED_SKILLS + 1))
  fi
done
if [ $REMOVED_SKILLS -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Removed $REMOVED_SKILLS skill(s) from .claude/skills/"
else
  echo -e "${YELLOW}!${NC} No Trapic skills found in .claude/skills/"
fi

# ── 5. Remove token (optional) ───────────────────────────────────────
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ] && grep -q "TRAPIC_TOKEN" "$SETTINGS" 2>/dev/null; then
  echo ""
  read -p "  Remove TRAPIC_TOKEN from ~/.claude/settings.json? (y/N): " REMOVE_TOKEN < /dev/tty
  if [ "$REMOVE_TOKEN" = "y" ] || [ "$REMOVE_TOKEN" = "Y" ]; then
    python3 -c "
import json
p = '$SETTINGS'
d = json.load(open(p))
if 'env' in d and 'TRAPIC_TOKEN' in d['env']:
  del d['env']['TRAPIC_TOKEN']
  if not d['env']:
    del d['env']
  json.dump(d, open(p, 'w'), indent=2)
" 2>/dev/null
    echo -e "${GREEN}✓${NC} Token removed from $SETTINGS"
  else
    echo -e "${YELLOW}!${NC} Token kept in $SETTINGS"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}=== Uninstall complete ===${NC}"
echo ""
echo "  Restart Claude Code to apply changes."
echo ""
