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


@mcp.tool()
def show_rectangle(
    x: int, y: int, width: int, height: int, color: str = "red", duration: int = 10
) -> str:
    """Show a colored rectangle overlay on the screen (Windows only)

    Args:
        x: X coordinate of the top-left corner
        y: Y coordinate of the top-left corner
        width: Width of the rectangle in pixels
        height: Height of the rectangle in pixels
        color: Color of the rectangle border (default: red)
        duration: Duration in seconds to show the rectangle (default: 10)
    """

    def show_overlay():
        if sys.platform != "win32":
            return

        try:
            user32 = ctypes.windll.user32
            gdi32 = ctypes.windll.gdi32

            WNDCLASSW = ctypes.c_uint64

            class WNDCLASS(ctypes.Structure):
                _fields_ = [
                    ("style", ctypes.c_uint32),
                    ("lpfnWndProc", ctypes.c_void_p),
                    ("cbClsExtra", ctypes.c_int32),
                    ("cbWndExtra", ctypes.c_int32),
                    ("hInstance", ctypes.c_void_p),
                    ("hIcon", ctypes.c_void_p),
                    ("hCursor", ctypes.c_void_p),
                    ("hbrBackground", ctypes.c_void_p),
                    ("lpszMenuName", ctypes.c_wchar_p),
                    ("lpszClassName", ctypes.c_wchar_p),
                ]

            def wnd_proc(hwnd, msg, wparam, lparam):
                if msg == 2:
                    user32.DestroyWindow(hwnd)
                    return 0
                return user32.DefWindowProcW(hwnd, msg, wparam, lparam)

            WNDPROC = ctypes.WINFUNCTYPE(
                ctypes.c_int64,
                ctypes.c_void_p,
                ctypes.c_uint32,
                ctypes.c_uint64,
                ctypes.c_int64,
            )

            wc = WNDCLASS()
            wc.style = 0x0008
            wc.lpfnWndProc = WNDPROC(wnd_proc)
            wc.hInstance = ctypes.windll.kernel32.GetModuleHandleW(None)
            wc.lpszClassName = "RectangleOverlay"

            if not user32.RegisterClassW(ctypes.byref(wc)):
                return

            hwnd = user32.CreateWindowExW(
                0x00000080,
                "RectangleOverlay",
                "",
                0x80000000 | 0x08000000,
                x,
                y,
                width,
                height,
                None,
                None,
                wc.hInstance,
                None,
            )

            if not hwnd:
                return

            user32.SetLayeredWindowAttributes(hwnd, 0, 128, 0x00000002)
            user32.ShowWindow(hwnd, 1)

            hdc = user32.GetDC(hwnd)
            pen = gdi32.CreatePen(
                0, 4, 0x000000FF if color.lower() == "red" else 0x00FF0000
            )
            old_pen = gdi32.SelectObject(hdc, pen)

            gdi32.Rectangle(hdc, 0, 0, width, height)
            gdi32.SelectObject(hdc, old_pen)
            gdi32.DeleteObject(pen)
            user32.ReleaseDC(hwnd, hdc)

            time.sleep(duration)
            user32.DestroyWindow(hwnd)

        except Exception as e:
            pass

    thread = threading.Thread(target=show_overlay, daemon=True)
    thread.start()
    return f"Showing rectangle at ({x}, {y}) with size {width}x{height} for {duration}s"


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
    print("  - show_rectangle: Show colored rectangle overlay (Windows)", flush=True)
    print("=" * 60, flush=True)
    print("Starting server...", flush=True)
    print(flush=True)

    mcp.run(transport=args.transport)
