from mcp.server.fastmcp import FastMCP

mcp = FastMCP("general-mcp-server")


@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers together"""
    return a + b


@mcp.tool()
def multiply(x: int, y: int) -> int:
    """Multiply two numbers"""
    return x * y


@mcp.tool()
def subtract(a: int, b: int) -> int:
    """Subtract b from a"""
    return a - b


@mcp.tool()
def divide(a: float, b: float) -> float:
    """Divide a by b"""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b


@mcp.tool()
def get_current_time() -> str:
    """Get the current date and time"""
    from datetime import datetime

    return datetime.now().isoformat()


@mcp.tool()
def reverse_string(text: str) -> str:
    """Reverse a string"""
    return text[::-1]


if __name__ == "__main__":
    mcp.run(transport="stdio")
