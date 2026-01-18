# PyAutoGUI MCP Server

An MCP (Model Context Protocol) server that provides GUI automation capabilities using PyAutoGUI. Designed for Windows coordinate debugging.

## Features

- **Text Input**: Type text using keyboard
- **Mouse Control**: Click, move, and scroll
- **Screenshot**: Capture screen as image or base64
- **Keyboard Shortcuts**: Press single keys or hotkey combinations
- **Visual Debug**: Show rectangle overlay for coordinate debugging (Windows only)

## Installation

Install dependencies:
```bash
pip install -r requirements.txt
```

## Running

Run the server:
```bash
python server.py
```

## MCP User Manual

This server implements the Model Context Protocol (MCP) for GUI automation. To use it:

1. **Start the server**:
   ```bash
   python server.py
   ```
   The server runs on stdio transport by default, suitable for MCP clients.

2. **Connect with an MCP client**:
   - The server communicates via stdin/stdout
   - MCP clients can discover and invoke the available tools
   - Transport modes: stdio (default), streamable-http, sse

3. **Tool invocation**:
   - Tools are called with JSON-RPC 2.0 messages
   - Each tool returns a string response or data
   - Errors are handled gracefully with descriptive messages

## Available Tools

| Tool | Description |
|------|-------------|
| `type_text(text, interval)` | Type text with optional delay between keystrokes |
| `click(x, y, clicks, button)` | Click at coordinates or current position |
| `screenshot(save_path)` | Take screenshot and save to file or return as base64 |
| `get_mouse_position()` | Get current mouse coordinates |
| `key_press(keys)` | Press keyboard keys (e.g., 'enter', 'ctrl+c') |
| `hotkey_press(*keys)` | Press multiple keys simultaneously |
| `move_mouse(x, y, duration)` | Move mouse to coordinates with animation |
| `scroll(clicks)` | Scroll mouse wheel |
| `open_rect()` | Open Windows Snipping Tool |
| `show_window_size()` | Get size of active window (Windows only) |
| `rect_info()` | Get position and size of Snipping Tool window (Windows only) |

## Safety

The server includes a fail-safe mechanism that interrupts the script if the mouse is moved to the upper-left corner of the screen.

## Platform

The `show_rectangle` tool is designed for Windows and uses Windows API to create overlay windows. Other tools are cross-platform.

## Example Usage

```python
# Type text
type_text("Hello World")

# Click at coordinates
click(x=500, y=300)

# Take screenshot
screenshot(save_path="screenshot.png")

# Get mouse position
get_mouse_position()

# Show rectangle for coordinate debugging (Windows only)
show_rectangle(x=100, y=100, width=200, height=150, color="red", duration=10)
```

## Testing

### Unit Tests

Run the automated unit tests:
```bash
python -m pytest test_show_rectangle.py -v
```

### Manual Testing

Run the manual test script for visual verification (Windows only):
```bash
python test_rectangle_manual.py
```

This provides several test modes:
1. Basic rectangle display
2. Corner positions
3. Different sizes
4. Duration timing
5. Interactive mode
6. Run all tests

### Test Coverage

The unit tests cover:
- Basic functionality and return values
- Default and custom parameters
- Windows API mocking
- Platform-specific behavior
- Edge cases (negative coordinates, large dimensions)
- Thread creation

Manual tests verify actual window display on Windows.

## OpenCode Integration

This MCP server can be integrated with [OpenCode](https://opencode.ai) for AI-powered GUI automation capabilities.

### Quick Setup

1. **Start the MCP server in background:**
   ```bash
   # On Windows
   start_server.bat

   # On Linux/macOS
   chmod +x start_server.sh
   ./start_server.sh
   ```

2. **Configure OpenCode:**
   Add the following to your OpenCode config file (`~/.config/opencode/config.json`):

   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "mcp": {
       "pyautogui": {
         "type": "remote",
         "url": "http://localhost:8050/mcp",
         "enabled": true,
         "description": "PyAutoGUI MCP Server - GUI automation tools"
       }
     }
   }
   ```

3. **Use in OpenCode:**
   In your OpenCode prompts, you can now use PyAutoGUI tools:
   ```
   Take a screenshot of the current screen and save it as screenshot.png. use pyautogui
   ```

   ```
   Move the mouse to coordinates (500, 300) and click. use pyautogui
   ```

### System Service Setup (Linux)

For production use, install as a system service:

1. Copy the service file:
   ```bash
   sudo cp pyautogui-mcp.service /etc/systemd/system/
   ```

2. Edit the service file to set the correct paths and user:
   ```bash
   sudo nano /etc/systemd/system/pyautogui-mcp.service
   # Update WorkingDirectory, ExecStart, and User
   ```

3. Enable and start the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable pyautogui-mcp
   sudo systemctl start pyautogui-mcp
   sudo systemctl status pyautogui-mcp
   ```

### Remote Access

For remote access, you can expose the server through a reverse proxy or cloud service. Make sure to:

1. Configure proper authentication/authorization
2. Use HTTPS in production
3. Limit network access to trusted IPs

The server supports all MCP transport modes:
- `stdio` - For local CLI usage
- `streamable-http` - For HTTP API access
- `sse` - For Server-Sent Events

### Configuration File

A sample OpenCode configuration is provided in `opencode-mcp-config.json` that you can merge into your global OpenCode config.