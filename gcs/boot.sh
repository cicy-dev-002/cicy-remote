source

if [ -f ~/gcs-env.sh ]; then
  source ~/gcs-env.sh
fi

if [ -f /content/gcs-env.sh ]; then
  source /content/gcs-env.sh
fi

bash <(curl -fsSL https://raw.githubusercontent.com/cicybot/cloudflare-tunnel-proxy/refs/heads/main/install-cloudflared.sh)

pkill cloudflared
nohup cloudflared tunnel run --token "$CF_TUNNEL" > ~/tunnel.log 2>&1 &

ps aux | grep cloudflared
