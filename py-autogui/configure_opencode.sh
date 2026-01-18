#!/bin/bash
# OpenCode MCP Configuration Script
# This script helps configure the PyAutoGUI MCP server with OpenCode

echo "PyAutoGUI MCP Server - OpenCode Configuration"
echo "=============================================="

# Check if opencode is installed
if ! command -v opencode &> /dev/null; then
    echo "Error: OpenCode is not installed. Please install it first:"
    echo "  curl -fsSL https://opencode.ai/install | bash"
    exit 1
fi

# Determine config file location
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_DIR="$HOME/.config/opencode"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/opencode"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    CONFIG_DIR="$APPDATA/opencode"
else
    CONFIG_DIR="$HOME/.config/opencode"
fi

CONFIG_FILE="$CONFIG_DIR/config.json"

echo "OpenCode config location: $CONFIG_FILE"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating new OpenCode config file..."
    cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {}
}
EOF
fi

# Backup existing config
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
echo "Backup created: $CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Get server URL from user
read -p "Enter PyAutoGUI MCP server URL [http://localhost:8050/mcp]: " SERVER_URL
SERVER_URL=${SERVER_URL:-http://localhost:8050/mcp}

# Get current directory for server path
SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add PyAutoGUI MCP config to OpenCode config
python3 -c "
import json
import sys

config_file = '$CONFIG_FILE'
server_url = '$SERVER_URL'

# Read existing config
try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {'$schema': 'https://opencode.ai/config.json'}

# Ensure mcp section exists
if 'mcp' not in config:
    config['mcp'] = {}

# Add PyAutoGUI server config
config['mcp']['pyautogui'] = {
    'type': 'remote',
    'url': server_url,
    'enabled': True,
    'description': 'PyAutoGUI MCP Server - GUI automation tools for mouse control, keyboard input, screenshot capture, and visual debugging overlays'
}

# Write updated config
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f'PyAutoGUI MCP server configured in OpenCode config: {config_file}')
print(f'Server URL: {server_url}')
"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Configuration successful!"
    echo ""
    echo "Next steps:"
    echo "1. Start the PyAutoGUI MCP server:"
    echo "   ./start_server.sh"
    echo ""
    echo "2. In OpenCode, you can now use PyAutoGUI tools by adding 'use pyautogui' to your prompts"
    echo ""
    echo "Example prompts:"
    echo "  'Take a screenshot and save it as image.png. use pyautogui'"
    echo "  'Move mouse to (100, 200) and click. use pyautogui'"
    echo "  'Type \"Hello World\" using keyboard. use pyautogui'"
else
    echo "❌ Configuration failed. Please check the error messages above."
    exit 1
fi