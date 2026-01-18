# Agent Development Guide

This guide provides instructions for agentic coding assistants working on the PyAutoGUI MCP Server project.

## Project Overview

PyAutoGUI MCP Server is a Model Context Protocol (MCP) server that provides GUI automation capabilities using PyAutoGUI. It includes tools for mouse control, keyboard input, screenshot capture, opening applications, and retrieving window information. The project emphasizes cross-platform compatibility with Windows-specific features gracefully degrading on other platforms.

## Build, Lint, and Test Commands

### Testing
- **Run all tests**: `python -m pytest -v`
- **Run specific test file**: `python -m pytest test_show_rectangle.py -v`
- **Run single test**: `python -m pytest test_show_rectangle.py::TestShowRectangle::test_show_rectangle_returns_success_message -v`
- **Collect tests without running**: `python -m pytest --collect-only`
- **Run with coverage**: `python -m pytest --cov=server --cov-report=html`

### Manual Testing
- **Rectangle overlay tests**: `python test_rectangle_manual.py`
- **Server startup tests**: `python test_server_startup.py`

### Installation and Setup
- **Install dependencies**: `pip install -r requirements.txt`
- **Run server**: `python server.py`
- **Run with specific transport**: `python server.py --transport streamable-http --port 8050`

### Linting and Formatting (Recommended Setup)
Consider adding these tools for code quality:
- **Black** for code formatting: `pip install black && black .`
- **Flake8** for linting: `pip install flake8 && flake8 --max-line-length=100`
- **MyPy** for type checking: `pip install mypy && mypy . --ignore-missing-imports`

## Code Style Guidelines

### Imports
- Group imports in this order: standard library, third-party, local
- Use absolute imports for clarity
- Separate groups with blank lines
- Import specific modules/functions rather than wildcard imports

```python
import sys
import time
from typing import Optional

import pyautogui
from PIL import Image

from server import show_rectangle
```

### Naming Conventions
- **Functions and variables**: snake_case (e.g., `get_mouse_position`, `click_count`)
- **Classes**: PascalCase (e.g., `TestShowRectangle`, `MouseController`)
- **Constants**: UPPER_CASE (e.g., `DEFAULT_DURATION = 10`, `MAX_RECTANGLE_SIZE = 5000`)
- **Methods**: snake_case, descriptive names (e.g., `create_overlay_window`)
- **Private methods**: prefix with single underscore (e.g., `_validate_coordinates`)

### Type Hints
- Use type hints for all function parameters and return values
- Use `Optional` for nullable types
- Include type hints for complex data structures
- Use `Union` for multiple possible types
- Use `List`, `Dict`, `Tuple` from typing module

```python
def click(x: Optional[int] = None, y: Optional[int] = None,
          clicks: int = 1, button: str = "left") -> str:
    # Implementation

def get_position() -> tuple[int, int]:
    # Implementation
```

### Docstrings
- Use triple-quoted strings for all public functions
- Follow Google-style docstrings with Args/Returns sections
- Include parameter descriptions and types
- Document exceptions that may be raised
- Keep descriptions concise but informative

```python
def show_rectangle(
    x: int, y: int, width: int, height: int,
    color: str = "red", duration: int = 10
) -> str:
    """Show a colored rectangle overlay on the screen (Windows only)

    Args:
        x: X coordinate of the top-left corner
        y: Y coordinate of the top-left corner
        width: Width of the rectangle in pixels
        height: Height of the rectangle in pixels
        color: Color of the rectangle border (default: red)
        duration: Duration in seconds to show the rectangle (default: 10)

    Returns:
        String confirming rectangle display

    Raises:
        ValueError: If coordinates are invalid
    """
```

### Error Handling
- Use try/except blocks for external operations (Windows API, file I/O)
- Check platform compatibility before platform-specific operations
- Return descriptive error messages rather than raising exceptions in MCP tools
- Log errors with appropriate levels
- Validate input parameters at function entry

```python
def get_window_size() -> str:
    if sys.platform != "win32":
        return "Window size detection is only available on Windows"

    try:
        # Windows API calls
        user32 = ctypes.windll.user32
        # ... operations
    except Exception as e:
        return f"Error getting window size: {e}"
```

### Code Structure
- Use descriptive variable names (avoid single letters except for coordinates like `x`, `y`)
- Break complex functions into smaller, focused functions (max 50 lines)
- Use early returns to reduce nesting
- Group related functionality into classes or modules
- Include input validation at function boundaries

```python
def validate_coordinates(x: int, y: int) -> bool:
    """Validate that coordinates are within screen bounds"""
    screen_width, screen_height = pyautogui.size()
    return 0 <= x <= screen_width and 0 <= y <= screen_height

def click(x: int = None, y: int = None, **kwargs) -> str:
    if x is None or y is None:
        x, y = pyautogui.position()

    if not validate_coordinates(x, y):
        return f"Invalid coordinates: ({x}, {y})"

    # Perform click operation
```

### Constants and Magic Numbers
- Define constants for all magic numbers
- Use descriptive names for configuration values
- Group related constants together

```python
# Timing constants
DEFAULT_CLICK_INTERVAL = 0.1
DEFAULT_DURATION = 10
MAX_RECTANGLE_DURATION = 300

# Size limits
MAX_RECTANGLE_SIZE = 5000
MIN_RECTANGLE_SIZE = 10

# Colors
SUPPORTED_COLORS = ["red", "blue", "green"]
```

### Threading and Concurrency
- Use daemon threads for GUI operations to prevent blocking
- Handle thread cleanup properly
- Use `threading.Thread` with `daemon=True` for background tasks
- Avoid shared mutable state between threads when possible

```python
def show_overlay():
    # Overlay implementation
    pass

thread = threading.Thread(target=show_overlay, daemon=True)
thread.start()
```

### Platform-Specific Code
- Check `sys.platform` before platform-specific operations
- Provide graceful degradation for unsupported platforms
- Document platform limitations clearly
- Use feature detection rather than platform detection when possible

```python
def get_active_window_info() -> dict:
    if sys.platform != "win32":
        return {"error": "This feature is only available on Windows"}

    # Windows-specific implementation
```

### Windows API Usage
- Import ctypes modules at function level when needed
- Define structures using `ctypes.Structure` for Windows API calls
- Handle Windows API errors gracefully
- Clean up resources (handles, DCs) properly

### Testing Patterns
- Use `unittest.TestCase` for unit tests
- Mock Windows API calls using `unittest.mock`
- Skip platform-specific tests on unsupported platforms
- Test both success and error conditions
- Use descriptive test method names

```python
@unittest.skipUnless(sys.platform == "win32", "Windows API test only")
def test_windows_specific_feature(self):
    with patch("ctypes.windll.user32") as mock_user32:
        # Test implementation
```

### Command Line Interface
- Use `argparse` for command-line arguments
- Provide sensible defaults
- Include help text for all arguments
- Support multiple transport modes

### Logging and Output
- Use `print()` with `flush=True` for real-time output
- Format output with clear separators for readability
- Avoid logging sensitive information
- Use consistent message formats

### Security Considerations
- Include fail-safe mechanisms (PyAutoGUI.FAILSAFE)
- Validate input parameters to prevent injection
- Avoid exposing system internals through API responses
- Sanitize file paths and user inputs

### Performance
- Use efficient data structures
- Minimize blocking operations
- Consider threading for GUI operations that might block
- Cache expensive operations when appropriate

## Project Structure

```
py-autogui/
├── server.py                 # Main MCP server implementation
├── requirements.txt          # Python dependencies
├── README.md                # Project documentation
├── AGENTS.md                # This development guide
├── test_show_rectangle.py   # Unit tests for rectangle functionality
├── test_server_startup.py  # Server startup tests
├── test_rectangle_manual.py # Manual/visual tests
├── configure_opencode.*     # OpenCode integration scripts
├── start_server.*          # Server startup scripts
└── opencode-mcp-config.json # OpenCode configuration
```

## Development Workflow

1. **Setup**: `pip install -r requirements.txt`
2. **Test**: `python -m pytest -v` (run tests frequently)
3. **Manual Test**: `python test_rectangle_manual.py` (for visual verification on Windows)
4. **Lint**: Add linting tools and run them regularly
5. **Document**: Update docstrings and README for new features
6. **Type Check**: Run mypy to ensure type safety

## Key Considerations

- **Cross-platform compatibility**: Core functionality works on all platforms, Windows-specific features gracefully degrade
- **Thread safety**: GUI operations run in separate threads to avoid blocking the MCP server
- **Error resilience**: Functions return descriptive messages rather than crashing
- **Type safety**: Use type hints throughout for better IDE support and documentation
- **Security**: Validate all inputs and include fail-safe mechanisms
- **Performance**: Use threading for non-blocking GUI operations