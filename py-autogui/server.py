from mcp.server.fastmcp import FastMCP
import pyautogui
import base64
from io import BytesIO
from PIL import Image
import threading
import subprocess
import time
import sys
import argparse
import os
import ctypes
import tkinter as tk

# Initialize MCP server after parsing arguments
mcp = FastMCP("pyautogui-mcp-server")
from typing import Optional

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
def click(x: Optional[int] = None, y: Optional[int] = None, clicks: int = 1, button: str = "left") -> str:
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
def screenshot(save_path: Optional[str] = None) -> str:
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


# @mcp.tool()
def open_rect() -> str:
    """Open Windows Snipping Tool for taking screenshots"""

    if sys.platform != "win32":
        return "Snipping Tool is only available on Windows"

    try:
        subprocess.Popen(["snippingtool.exe"])
        return "Snipping Tool opened"
    except Exception as e:
        return f"Error opening Snipping Tool: {e}"


@mcp.tool()
def show_window_size() -> str:
    """Get the size of the currently active window (Windows only)

    Returns:
        String with window width and height
    """
    if sys.platform != "win32":
        return "Window size detection is only available on Windows"

    try:
        user32 = ctypes.windll.user32

        class RECT(ctypes.Structure):
            _fields_ = [
                ("left", ctypes.c_long),
                ("top", ctypes.c_long),
                ("right", ctypes.c_long),
                ("bottom", ctypes.c_long),
            ]

        hwnd = user32.GetForegroundWindow()
        if not hwnd:
            return "No active window found"

        rect = RECT()
        if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
            return "Failed to get window rectangle"

        width = rect.right - rect.left
        height = rect.bottom - rect.top

        return f"Active window size: {width}x{height}"

    except Exception as e:
        return f"Error getting window size: {e}"


@mcp.tool()
def rect_info() -> str:
    """Get the position and size of the Snipping Tool window (Windows only)

    Returns:
        String with Snipping Tool position and size
    """
    if sys.platform != "win32":
        return "Snipping Tool info is only available on Windows"

    try:
        user32 = ctypes.windll.user32

        class RECT(ctypes.Structure):
            _fields_ = [
                ("left", ctypes.c_long),
                ("top", ctypes.c_long),
                ("right", ctypes.c_long),
                ("bottom", ctypes.c_long),
            ]

        hwnd = user32.FindWindowW(None, "Snipping Tool")
        if not hwnd:
            return "Snipping Tool not found"

        rect = RECT()
        if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
            return "Failed to get window rectangle"

        width = rect.right - rect.left
        height = rect.bottom - rect.top

        return f"Snipping Tool position: ({rect.left}, {rect.top}), size: {width}x{height}"

    except Exception as e:
        return f"Error getting Snipping Tool info: {e}"


# @mcp.tool()
def get_active_window_size() -> str:
    """Get the size of the currently active window (Windows only)

    Returns:
        String with window width and height
    """
    if sys.platform != "win32":
        return "Window size detection is only available on Windows"

    try:
        user32 = ctypes.windll.user32

        class RECT(ctypes.Structure):
            _fields_ = [
                ("left", ctypes.c_long),
                ("top", ctypes.c_long),
                ("right", ctypes.c_long),
                ("bottom", ctypes.c_long),
            ]

        hwnd = user32.GetForegroundWindow()
        if not hwnd:
            return "No active window found"

        rect = RECT()
        if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
            return "Failed to get window rectangle"

        width = rect.right - rect.left
        height = rect.bottom - rect.top

        return f"Active window size: {width}x{height}"

    except Exception as e:
        return f"Error getting window size: {e}"


# @mcp.tool()
def get_window_position() -> str:
    """Get the position of the currently active window (Windows only)

    Returns:
        String with window x,y coordinates
    """
    if sys.platform != "win32":
        return "Window position detection is only available on Windows"

    try:
        user32 = ctypes.windll.user32

        class RECT(ctypes.Structure):
            _fields_ = [
                ("left", ctypes.c_long),
                ("top", ctypes.c_long),
                ("right", ctypes.c_long),
                ("bottom", ctypes.c_long),
            ]

        hwnd = user32.GetForegroundWindow()
        if not hwnd:
            return "No active window found"

        rect = RECT()
        if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
            return "Failed to get window rectangle"

        return f"Active window position: ({rect.left}, {rect.top})"

    except Exception as e:
        return f"Error getting window position: {e}"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PyAutoGUI MCP Server")
    parser.add_argument(
        "--transport",
        choices=["stdio", "streamable-http", "sse"],
        default="stdio",
        help="Transport protocol to use (default: stdio)",
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Host to bind to for HTTP/SSE transport (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8050,
        help="Port to bind to for HTTP/SSE transport (default: 8050)",
    )

    args = parser.parse_args()

    print("=" * 60, flush=True)
    print("PyAutoGUI MCP Server", flush=True)
    print("=" * 60, flush=True)
    print(f"Transport: {args.transport}", flush=True)

    if args.transport == "stdio":
        print("Protocol: stdin/stdout", flush=True)
        print("Use with MCP client that supports stdio transport", flush=True)
    elif args.transport == "streamable-http":
        os.environ["HOST"] = args.host
        os.environ["PORT"] = str(args.port)
        print(f"URL: http://{args.host}:{args.port}/mcp", flush=True)
        print(f"Server listening on {args.host}:{args.port}", flush=True)
    elif args.transport == "sse":
        os.environ["HOST"] = args.host
        os.environ["PORT"] = str(args.port)
        print(f"URL: http://{args.host}:{args.port}/sse", flush=True)
        print(f"Server listening on {args.host}:{args.port}", flush=True)

    print("=" * 60, flush=True)
    print("Available tools:", flush=True)
    print("  - type_text: Type text using keyboard", flush=True)
    print("  - click: Click at coordinates or current position", flush=True)
    print("  - screenshot: Take screenshot and save or return as base64", flush=True)
    print("  - get_mouse_position: Get current mouse coordinates", flush=True)
    print("  - key_press: Press keyboard keys", flush=True)
    print("  - hotkey_press: Press multiple keys simultaneously", flush=True)
    print("  - move_mouse: Move mouse to coordinates with animation", flush=True)
    print("  - scroll: Scroll mouse wheel", flush=True)
    print("  - open_rect: Open Windows Snipping Tool", flush=True)
    print("  - show_window_size: Get size of active window (Windows)", flush=True)
    print("  - rect_info: Get position and size of Snipping Tool (Windows)", flush=True)
    print("=" * 60, flush=True)
    print("Starting server...", flush=True)
    print(flush=True)

    mcp.run(transport=args.transport)
