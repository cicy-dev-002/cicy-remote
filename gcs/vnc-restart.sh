#!/bin/bash

# VNC Restart Script with Fixed Resolution
# 重启VNC并确保使用1920x1080分辨率

set -e

# 配置
VNC_DISPLAY=":1"
VNC_GEOMETRY="1920x1080"
VNC_DEPTH="24"
NOVNC_PORT="6080"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔄 重启VNC服务器并设置分辨率为 1920x1080${NC}"

# 停止所有VNC相关进程
echo "停止现有VNC进程..."
pkill -f "Xtigervnc.*:1" 2>/dev/null || true
pkill -f "websockify.*6080" 2>/dev/null || true
tigervncserver -kill $VNC_DISPLAY 2>/dev/null || true

# 等待进程完全停止
sleep 3

echo "启动VNC服务器，分辨率: $VNC_GEOMETRY"
# 启动VNC服务器，强制指定分辨率
tigervncserver $VNC_DISPLAY -geometry $VNC_GEOMETRY -depth $VNC_DEPTH -xstartup ~/.vnc/xstartup

# 等待VNC启动
sleep 3

# 检查VNC是否正确启动
if pgrep -f "Xtigervnc $VNC_DISPLAY" > /dev/null; then
    # 验证实际分辨率
    ACTUAL_GEOMETRY=$(ps aux | grep "Xtigervnc $VNC_DISPLAY" | grep -o "\-geometry [^ ]*" | cut -d' ' -f2 | tr -d '\n')
    echo -e "${GREEN}✅ VNC服务器已启动${NC}"
    echo -e "${BLUE}📺 设置分辨率: ${YELLOW}$VNC_GEOMETRY${NC}"
    echo -e "${BLUE}📺 实际分辨率: ${YELLOW}$ACTUAL_GEOMETRY${NC}"
else
    echo -e "${RED}❌ VNC启动失败${NC}"
    exit 1
fi

# 启动web接口
echo "启动noVNC web接口..."
websockify --web /usr/share/novnc/ $NOVNC_PORT localhost:${VNC_DISPLAY#:1}5901 &

# 等待web接口启动
sleep 2

if pgrep -f "websockify.*$NOVNC_PORT" > /dev/null; then
    echo -e "${GREEN}✅ Web接口已启动${NC}"
else
    echo -e "${RED}❌ Web接口启动失败${NC}"
fi

# 显示连接信息
IP=$(hostname -I | awk '{print $1}')
echo ""
echo -e "${GREEN}=== VNC重启完成！ ===${NC}"
echo ""
echo -e "${BLUE}🌐 Web访问 (noVNC):${NC}"
echo -e "   URL: ${YELLOW}http://$IP:$NOVNC_PORT/vnc.html${NC}"
echo -e "   密码: ${YELLOW}vnc123456${NC}"
echo ""
echo -e "${BLUE}🖥️ 直接VNC访问:${NC}"
echo -e "   地址: ${YELLOW}$IP:${VNC_DISPLAY#:1}5901${NC}"
echo -e "   密码: ${YELLOW}vnc123456${NC}"
echo ""
echo -e "${BLUE}📺 分辨率确认:${NC}"
echo -e "   设置: ${YELLOW}$VNC_GEOMETRY${NC}"
echo -e "   实际: ${YELLOW}$ACTUAL_GEOMETRY${NC}"
echo ""
