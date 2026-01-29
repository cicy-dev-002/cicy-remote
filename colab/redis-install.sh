#!/bin/bash

# Redis One-Key Install and Start Script
# Password: pwd123456

set -e

# Check if Redis is installed
if ! command -v redis-server &> /dev/null; then
    echo "📦 Installing Redis..."
    sudo apt-get update
    sudo apt-get install -y redis-server
else
    echo "✅ Redis is already installed"
fi

# Configure Redis config for external connections
echo "🔧 Configuring Redis..."
REDIS_CONF="/etc/redis/redis.conf"

# Try to find Redis config file
if [ ! -f "$REDIS_CONF" ]; then
    REDIS_CONF=$(find /etc -name "*redis*.conf" 2>/dev/null | head -1)
fi

if [ -f "$REDIS_CONF" ]; then
    # Allow external connections
    sudo sed -i 's/^bind 127.0.0.1 ::1/# bind 127.0.0.1 ::1/' "$REDIS_CONF"
    sudo sed -i 's/^protected-mode yes/protected-mode no/' "$REDIS_CONF"
else
    echo "❌ Redis configuration file not found at $REDIS_CONF"
    echo "📁 Available Redis config files:"
    sudo find /etc -name "*redis*.conf" 2>/dev/null
    exit 1
fi

# Create logs directory
echo "📁 Creating logs directory..."
mkdir -p ~/logs

# Check if Redis is already running
if pgrep redis-server > /dev/null; then
    echo "🛑 Stopping existing Redis process..."
    pkill redis-server
    sleep 2
fi

# Start Redis with nohup and password
echo "🚀 Starting Redis with nohup and password..."
nohup redis-server "$REDIS_CONF" --requirepass pwd123456 >> ~/logs/redis.log 2>&1 &

# Verify Redis is running
echo "🔍 Verifying Redis installation..."
sleep 2

if pgrep redis-server > /dev/null; then
    echo "✅ Redis is running successfully!"
    echo ""
    echo "📋 Connection Details:"
    echo "   Host: localhost (or 0.0.0.0 for external access)"
    echo "   Port: 6379"
    echo "   Password: pwd123456"
    echo ""
    echo "🧪 Test connection:"
    echo "   redis-cli -a pwd123456 ping"
    echo ""
    echo "🔧 Management Commands:"
    echo "   Stop: pkill redis-server"
    echo "   Restart: pkill redis-server && nohup redis-server \"$REDIS_CONF\" >> ~/logs/redis.log 2>&1 &"
    echo "   Logs: tail -f ~/logs/redis.log"
    echo "   Status: ps aux | grep redis-server"
else
    echo "❌ Redis failed to start"
    exit 1
fi