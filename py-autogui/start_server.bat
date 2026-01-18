@echo off
REM PyAutoGUI MCP Server Startup Script for Windows
REM This script starts the PyAutoGUI MCP server in the background

echo Starting PyAutoGUI MCP Server...

REM Change to the script directory
cd /d "%~dp0"

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "requirements.txt" (
    echo Error: requirements.txt not found
    pause
    exit /b 1
)

REM Install dependencies if not already installed
pip install -r requirements.txt

REM Start the server in background using streamable-http transport
REM The server will be accessible at http://localhost:8050/mcp
start /B python server.py --transport streamable-http --host 0.0.0.0 --port 8050

echo PyAutoGUI MCP Server started in background
echo Server URL: http://localhost:8050/mcp
echo Press any key to exit (server will continue running)...
pause >nul