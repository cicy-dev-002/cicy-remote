from mcp.server.fastmcp import FastMCP
import pyautogui
import base64
from io import BytesIO
from PIL import Image

mcp = FastMCP("pyautogui-mcp-server")

pyautogui.FAILSAFE = True


@mcp.tool()
def type_text(text: str, interval: float = 0.1) -> str:
    """Type text using keyboard

    Args:
        text: The text to type
        interval: Delay between key presses in seconds (default: 0.1)
    """
    pyautogui.write(text, interval=interval)
    return f"Typed: {text[:50]}{'...' if len(text) > 50 else ''}"


@mcp.tool()
def click(x: int = None, y: int = None, clicks: int = 1, button: str = "left") -> str:
    """Click at specified coordinates or current position

    Args:
        x: X coordinate (if None, clicks at current position)
        y: Y coordinate (if None, clicks at current position)
        clicks: Number of clicks (default: 1)
        button: Mouse button to use: left, right, middle (default: left)
    """
    if x is None or y is None:
        x, y = pyautogui.position()

    pyautogui.click(x, y, clicks=clicks, button=button)
    return f"Clicked at ({x}, {y}) with {button} button {clicks} time(s)"


@mcp.tool()
def screenshot(save_path: str = None) -> str:
    """Take a screenshot of the primary monitor

    Args:
        save_path: Path to save the screenshot (optional, returns base64 if not provided)

    Returns:
        Base64 encoded screenshot or success message
    """
    if save_path:
        pyautogui.screenshot(save_path)
        return f"Screenshot saved to: {save_path}"
    else:
        screenshot = pyautogui.screenshot()
        buffered = BytesIO()
        screenshot.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode()
        return f"data:image/png;base64,{img_str}"


@mcp.tool()
def get_mouse_position() -> str:
    """Get current mouse position"""
    x, y = pyautogui.position()
    return f"Current mouse position: ({x}, {y})"


@mcp.tool()
def key_press(keys: str) -> str:
    """Press keyboard keys

    Args:
        keys: Key or combination of keys to press (e.g., 'ctrl+c', 'enter', 'space')
    """
    pyautogui.press(keys)
    return f"Pressed: {keys}"


@mcp.tool()
def hotkey_press(*keys: str) -> str:
    """Press multiple keys simultaneously (hotkey)

    Args:
        keys: Keys to press together (e.g., 'ctrl', 'shift', 'alt', 'delete')
    """
    pyautogui.hotkey(*keys)
    return f"Pressed hotkey: {'+'.join(keys)}"


@mcp.tool()
def move_mouse(x: int, y: int, duration: float = 0.5) -> str:
    """Move mouse to specified coordinates

    Args:
        x: X coordinate
        y: Y coordinate
        duration: Duration of movement in seconds (default: 0.5)
    """
    pyautogui.moveTo(x, y, duration=duration)
    return f"Moved mouse to ({x}, {y}) over {duration}s"


@mcp.tool()
def scroll(clicks: int) -> str:
    """Scroll mouse wheel

    Args:
        clicks: Number of clicks to scroll (positive for up, negative for down)
    """
    pyautogui.scroll(clicks)
    return f"Scrolled {clicks} clicks"


if __name__ == "__main__":
    mcp.run(transport="stdio")
