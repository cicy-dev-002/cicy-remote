
bash <(curl -fsSL https://raw.githubusercontent.com/cicybot/cloudflare-tunnel-proxy/refs/heads/main/install-cloudflared.sh)

if [ ! -f ~/env.sh ]; then
  echo "CF_TUNNEL=" > ~/env.sh
fi

sh ~/env.sh
pkill cloudflared
nohup cloudflared tunnel run --token "$CF_TUNNEL" > ~/tunnel.log 2>&1 &

## proxy
docker rm -f 3proxy
docker run --name 3proxy --rm -d -p "8082:3128/tcp" ghcr.io/tarampampam/3proxy:1

ps aux | grep cloudflared
docker ps
