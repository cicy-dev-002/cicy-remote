#!/bin/bash
# PyAutoGUI MCP Server Startup Script for Linux/macOS
# This script starts the PyAutoGUI MCP server in the background

echo "Starting PyAutoGUI MCP Server..."

# Change to the script directory
cd "$(dirname "$0")"

# Check if Python is available
if ! command -v python &> /dev/null; then
    echo "Error: Python is not installed or not in PATH"
    exit 1
fi

# Check if dependencies are installed
if [ ! -f "requirements.txt" ]; then
    echo "Error: requirements.txt not found"
    exit 1
fi

# Install dependencies if not already installed
pip install -r requirements.txt

# Start the server in background using streamable-http transport
# The server will be accessible at http://localhost:8050/mcp
nohup python server.py --transport streamable-http --host 0.0.0.0 --port 8050 > server.log 2>&1 &

echo "PyAutoGUI MCP Server started in background (PID: $!)"
echo "Server URL: http://localhost:8050/mcp"
echo "Logs are being written to server.log"
echo "To stop the server, run: kill $!"

# Optional: wait a moment to show server startup output
sleep 2
if ps -p $! > /dev/null; then
    echo "Server is running successfully"
else
    echo "Warning: Server may have failed to start. Check server.log for details"
fi