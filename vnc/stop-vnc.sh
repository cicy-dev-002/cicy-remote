#!/bin/bash

# VNC & noVNC Stop Script
# Stops VNC server and web interface

set -e

# Configuration
VNC_DISPLAY=":1"
NOVNC_PORT="6080"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🛑 Stopping VNC and noVNC Services...${NC}"

# Stop VNC server
if pgrep -f "Xtigervnc $VNC_DISPLAY" > /dev/null; then
    echo "Stopping VNC server on display $VNC_DISPLAY..."
    tigervncserver -kill $VNC_DISPLAY
    echo -e "${GREEN}✅ VNC server stopped${NC}"
else
    echo -e "${YELLOW}VNC server was not running${NC}"
fi

# Stop websockify
if pgrep -f "websockify.*$NOVNC_PORT" > /dev/null; then
    echo "Stopping noVNC web interface on port $NOVNC_PORT..."
    pkill -f "websockify.*$NOVNC_PORT"
    echo -e "${GREEN}✅ Web interface stopped${NC}"
else
    echo -e "${YELLOW}Web interface was not running${NC}"
fi

echo ""
echo -e "${GREEN}=== All Services Stopped! ===${NC}"
echo -e "${BLUE}🔄 To restart: ${YELLOW}./start-vnc.sh${NC}"
echo -e "${BLUE}📊 To check status: ${YELLOW}ps aux | grep -E '(vnc|websockify)'${NC}"
echo ""