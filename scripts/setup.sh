#!/bin/bash
# Trapic token setup — interactive guide

SHELL_RC="$HOME/.zshrc"
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

echo ""
echo "=== Trapic Setup ==="
echo ""

# Check if already configured
if [ -n "$TRAPIC_TOKEN" ]; then
  echo "TRAPIC_TOKEN is already set: ${TRAPIC_TOKEN:0:6}..."
  echo "Trapic plugin is ready to use."
  exit 0
fi

# Check if token exists in shell profile but not exported in current session
if grep -q "TRAPIC_TOKEN" "$SHELL_RC" 2>/dev/null; then
  echo "Found TRAPIC_TOKEN in $SHELL_RC but it's not loaded in this session."
  echo "Run: source $SHELL_RC"
  echo "Then restart Claude Code."
  exit 0
fi

echo "No TRAPIC_TOKEN found."
echo ""
echo "Steps:"
echo "  1. Go to https://trapic.ai and sign up / log in"
echo "  2. Copy your API token (starts with tr_)"
echo "  3. Run:"
echo ""
echo "     echo 'export TRAPIC_TOKEN=tr_YOUR_TOKEN' >> $SHELL_RC && source $SHELL_RC"
echo ""
echo "  4. Restart Claude Code"
echo ""
