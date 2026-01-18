# Server Startup Configuration

The PyAutoGUI MCP server now supports displaying startup information including transport type, server URL, and available tools.

## Command-Line Options

```bash
usage: server.py [-h] [--transport {stdio,streamable-http,sse}] [--host HOST] [--port PORT]

PyAutoGUI MCP Server

options:
  -h, --help            Show help message and exit
  --transport {stdio,streamable-http,sse}
                        Transport protocol to use (default: stdio)
  --host HOST           Host to bind to for HTTP/SSE transport (default: 127.0.0.1)
  --port PORT           Port to bind to for HTTP/SSE transport (default: 8050)
```

## Transport Types

### Stdio Transport (Default)
```bash
python server.py
# or
python server.py --transport stdio
```

**Output:**
```
============================================================
PyAutoGUI MCP Server
============================================================
Transport: stdio
Protocol: stdin/stdout
Use with MCP client that supports stdio transport
============================================================
Available tools:
  - type_text: Type text using keyboard
  - click: Click at coordinates or current position
  - screenshot: Take screenshot and save or return as base64
  - get_mouse_position: Get current mouse coordinates
  - key_press: Press keyboard keys
  - hotkey_press: Press multiple keys simultaneously
  - move_mouse: Move mouse to coordinates with animation
  - scroll: Scroll mouse wheel
  - show_rectangle: Show colored rectangle overlay (Windows)
============================================================
Starting server...
```

### Streamable-HTTP Transport
```bash
python server.py --transport streamable-http
# Custom host and port
python server.py --transport streamable-http --host 0.0.0.0 --port 9000
```

**Output:**
```
============================================================
PyAutoGUI MCP Server
============================================================
Transport: streamable-http
URL: http://127.0.0.1:8050/mcp
Server listening on 127.0.0.1:8050
============================================================
Available tools:
  - type_text: Type text using keyboard
  - click: Click at coordinates or current position
  - screenshot: Take screenshot and save or return as base64
  - get_mouse_position: Get current mouse coordinates
  - key_press: Press keyboard keys
  - hotkey_press: Press multiple keys simultaneously
  - move_mouse: Move mouse to coordinates with animation
  - scroll: Scroll mouse wheel
  - show_rectangle: Show colored rectangle overlay (Windows)
============================================================
Starting server...
```

### SSE Transport
```bash
python server.py --transport sse
# Custom host and port
python server.py --transport sse --host 0.0.0.0 --port 9000
```

**Output:**
```
============================================================
PyAutoGUI MCP Server
============================================================
Transport: sse
URL: http://127.0.0.1:8050/sse
Server listening on 127.0.0.1:8050
============================================================
Available tools:
  - type_text: Type text using keyboard
  - click: Click at coordinates or current position
  - screenshot: Take screenshot and save or return as base64
  - get_mouse_position: Get current mouse coordinates
  - key_press: Press keyboard keys
  - hotkey_press: Press multiple keys simultaneously
  - move_mouse: Move mouse to coordinates with animation
  - scroll: Scroll mouse wheel
  - show_rectangle: Show colored rectangle overlay (Windows)
============================================================
Starting server...
```

## Implementation Details

- **Environment Variables**: For HTTP/SSE transports, host and port are set as `HOST` and `PORT` environment variables
- **Output Flushing**: All print statements use `flush=True` to ensure output is displayed immediately
- **Default Values**:
  - Host: `127.0.0.1`
  - Port: `8050`
  - Transport: `stdio`

## Usage Examples

### Local Testing (stdio)
```bash
python server.py --transport stdio
```

### Remote Access (HTTP)
```bash
# Bind to all interfaces for remote access
python server.py --transport streamable-http --host 0.0.0.0 --port 8050

# Specific interface
python server.py --transport streamable-http --host 192.168.1.100 --port 9000
```

### Browser-Based Clients (SSE)
```bash
python server.py --transport sse --host 0.0.0.0 --port 8050
```

## Client Configuration

For clients connecting to HTTP/SSE endpoints, use the URL shown in the startup output:

**Streamable-HTTP:**
```json
{
  "mcpServers": {
    "pyautogui": {
      "url": "http://127.0.0.1:8050/mcp",
      "transport": "http"
    }
  }
}
```

**SSE:**
```json
{
  "mcpServers": {
    "pyautogui": {
      "url": "http://127.0.0.1:8050/sse",
      "transport": "sse"
    }
  }
}
```