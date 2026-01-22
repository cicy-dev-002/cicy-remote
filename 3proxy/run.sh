#!/bin/bash

# Download, compile, and start 3proxy

echo "Downloading 3proxy source to /tmp..."
cd /tmp
rm -rf 3proxy-master
wget -q https://github.com/3proxy/3proxy/archive/master.zip
unzip -q master.zip

echo "Compiling 3proxy..."
cd 3proxy-master
make -f Makefile.Linux > /dev/null 2>&1

echo "Copying binary..."
cp bin/3proxy /root/3proxy/

cd /root/3proxy
mkdir -p logs

echo "Starting 3proxy..."
nohup ./3proxy 3proxy.cfg &

echo "3proxy started. PID: $!"
echo "Config: 3proxy.cfg"
echo "Logs: logs/"
echo "Admin: http://localhost:8080"
echo "To stop: kill $!"