#!/bin/bash
# XFCE VNC startup script

# 清除会话管理器
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

cd ~/mcp/app
nohup npm start &

# 启动XFCE桌面
exec startxfce4
