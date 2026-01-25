#!/usr/bin/env bash


bash <(curl -fsSL https://raw.githubusercontent.com/cicybot/cloudflare-tunnel-proxy/refs/heads/main/install-cloudflared.sh)

source /root/gcs-env.sh

echo $CLOUDFLARE_ACCOUNT_ID
cloudflared -v
pkill cloudflared
sleep 1
nohup cloudflared tunnel run --token $CF_TUNNEL > /root/tunnel.log 2>&1 &
ps aux | grep cloudflared


if [ ! -d ~/mcp ]; then
  git clone https://$GH_CICYBOT_TOKEN@github.com/cicybot/electron-mcp.git ~/mcp
fi

cd /root/mcp

cd ~/
ps aux | grep cloudflared
ps aux | grep jupyter
