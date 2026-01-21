#!/bin/bash

# VNC & noVNC Status Script
# Shows current status of VNC services

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

echo -e "${BLUE}📊 VNC & noVNC Status${NC}"
echo "================================"

# Check VNC server
if pgrep -f "Xtigervnc $VNC_DISPLAY" > /dev/null; then
    VNC_PID=$(pgrep -f "Xtigervnc $VNC_DISPLAY")
    VNC_GEOMETRY=$(ps aux | grep "Xtigervnc $VNC_DISPLAY" | grep -o "\-geometry [^ ]*" | cut -d' ' -f2)
    echo -e "🖥️  VNC Server: ${GREEN}Running${NC}"
    echo -e "   PID: ${YELLOW}$VNC_PID${NC}"
    echo -e "   Display: ${YELLOW}$VNC_DISPLAY${NC}"
    echo -e "   Resolution: ${YELLOW}$VNC_GEOMETRY${NC}"
    echo -e "   Port: ${YELLOW}5901${NC}"
else
    echo -e "🖥️  VNC Server: ${RED}Stopped${NC}"
fi

# Check websockify
if pgrep -f "websockify.*$NOVNC_PORT" > /dev/null; then
    WEBSOCK_PID=$(pgrep -f "websockify.*$NOVNC_PORT")
    echo -e "🌐 Web Interface: ${GREEN}Running${NC}"
    echo -e "   PID: ${YELLOW}$WEBSOCK_PID${NC}"
    echo -e "   Port: ${YELLOW}$NOVNC_PORT${NC}"
else
    echo -e "🌐 Web Interface: ${RED}Stopped${NC}"
fi

# Check desktop processes
if pgrep -f "xfce4-session" > /dev/null; then
    XFCE_PID=$(pgrep -f "xfce4-session")
    echo -e "🖼️  Desktop: ${GREEN}XFCE4 Running${NC} (PID: $XFCE_PID)"
else
    echo -e "🖼️  Desktop: ${RED}Not running${NC}"
fi

# Show connection info if running
IP=$(hostname -I | awk '{print $1}')
echo ""
if pgrep -f "Xtigervnc $VNC_DISPLAY" > /dev/null; then
    echo -e "${BLUE}📱 Connection Information:${NC}"
    echo -e "   Web: ${YELLOW}http://$IP:$NOVNC_PORT/vnc.html${NC}"
    echo -e "   VNC: ${YELLOW}$IP:5901${NC}"
    echo -e "   Password: ${YELLOW}vnc123456${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Management:${NC}"
echo -e "   Start: ${YELLOW}./start-vnc.sh${NC}"
echo -e "   Stop:  ${YELLOW}./stop-vnc.sh${NC}"
echo -e "   Restart: ${YELLOW}./stop-vnc.sh && ./start-vnc.sh${NC}"
echo ""