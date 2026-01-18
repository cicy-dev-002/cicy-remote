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
| `show_rectangle(x, y, width, height, color, duration)` | Show colored rectangle overlay on screen (Windows) |

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