#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

# Copy statusline script
cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"
echo "Copied statusline.sh to $CLAUDE_DIR/"

# Update settings.json with statusLine config
if [ -f "$SETTINGS" ]; then
  # Check if statusLine already configured
  if node -e "const s=JSON.parse(require('fs').readFileSync('$SETTINGS','utf8')); process.exit(s.statusLine ? 0 : 1)" 2>/dev/null; then
    echo "statusLine already configured in $SETTINGS"
  else
    # Add statusLine to existing settings
    node -e "
      const fs = require('fs');
      const s = JSON.parse(fs.readFileSync('$SETTINGS', 'utf8'));
      s.statusLine = { type: 'command', command: 'bash ~/.claude/statusline.sh' };
      fs.writeFileSync('$SETTINGS', JSON.stringify(s, null, 2) + '\n');
    "
    echo "Added statusLine config to $SETTINGS"
  fi
else
  # Create new settings file
  mkdir -p "$CLAUDE_DIR"
  cat > "$SETTINGS" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
EOF
  echo "Created $SETTINGS with statusLine config"
fi

echo "Done! Restart Claude Code to see your status line."
