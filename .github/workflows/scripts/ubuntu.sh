#System info
curl -fsSL api.myip.com | python -m json.tool
python --version
free -m
df -h

#Update APT
sudo apt-get update && sudo apt-get install -y xvfb  xkb-data

#Install Cloudflared
bash <(curl -fsSL https://raw.githubusercontent.com/cicybot/cloudflare-tunnel-proxy/refs/heads/main/install-cloudflared.sh)
cloudflared -v

nohup cloudflared tunnel run --token $CF_TUNNEL > ~/tunnel.log 2>&1 &

#Docker 3proxy Proxy
docker run --name 3proxy --rm -d -p "8082:3128/tcp" ghcr.io/tarampampam/3proxy:1
docker ps

#install Electron
#npm install electron -g
#git clone https://github.com/cicybot/electron-mcp.git
#cd electron-mcp
#sh electron.sh
#cd run
#Xvfb :1 -screen 0 1280x1024x24 &
#export DISPLAY=:1
#nohup electron  --no-sandbox --disable-software-rasterizer  --disable-gpu   --enable-unsafe-swiftshader   --disable-features=UseDBus   --log-level=3  main.js > ~/electron.log 2>&1 &
#sleep 2
#cat ~/electron.log
##Install Jupyter and Run Jupyter in background
#pip install --upgrade pip
#pip install jupyterlab
#jupyter --version
## Run Jupyter Lab in background
#nohup jupyter lab \
#  --ServerApp.token=$JUPYTER_TOKEN \
#  --ip=0.0.0.0 \
#  --port=8888 \
#  --ServerApp.allow_remote_access=True \
#  --ServerApp.trust_xheaders=True \
#  --no-browser > jupyter.log 2>&1 &

