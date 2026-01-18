# PyAutoGUI MCP Server

An MCP (Model Context Protocol) server that provides GUI automation capabilities using PyAutoGUI.

## Features

- **Text Input**: Type text using keyboard
- **Mouse Control**: Click, move, and scroll
- **Screenshot**: Capture screen as image or base64
- **Keyboard Shortcuts**: Press single keys or hotkey combinations

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

## Safety

The server includes a fail-safe mechanism that interrupts the script if the mouse is moved to the upper-left corner of the screen.

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
```