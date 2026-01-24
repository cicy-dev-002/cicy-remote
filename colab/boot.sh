#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

sudo apt update
sudo apt install -y locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
sudo debconf-set-selections <<< "keyboard-configuration keyboard-configuration/layoutcode string us"
sudo debconf-set-selections <<< "keyboard-configuration keyboard-configuration/modelcode string pc105"
sudo apt install -y \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-goodies \
    xterm \
    dbus-x11


sudo apt install -y \
    novnc \
    websockify

bash <(curl -fsSL https://raw.githubusercontent.com/cicybot/cloudflare-tunnel-proxy/refs/heads/main/install-cloudflared.sh)
source /root/gcs-env.sh

echo $CLOUDFLARE_ACCOUNT_ID
cloudflared -v
pkill cloudflared
sleep 1
nohup cloudflared tunnel run --token $CF_TUNNEL > /root/tunnel.log 2>&1 &
ps aux | grep cloudflared

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
node -v

curl -fsSL https://opencode.ai/install | bash
grep -qxF "alias oc='~/.opencode/bin/opencode'" ~/.bashrc || echo "alias oc='~/.opencode/bin/opencode'" >> ~/.bashrc
source /root/.bashrc

oc -v
sudo apt install python3-tk  python3-dev -y
pip install pyautogui pyperclip pillow pyscreeze
pip install jupyterlab

cd /root/

sudo fuser -k 8889/tcp

nohup jupyter lab \
  --no-browser \
  --IdentityProvider.token=$JUPYTER_TOKEN \
  --ip=127.0.0.1 \
  --port=8889 \
  --ServerApp.allow_remote_access=True \
  --ServerApp.trust_xheaders=True \
  > /root/jupyter_lab.log 2>&1 &


if [ ! -d ~/mcp ]; then
  git clone https://$GH_CICYBOT_TOKEN@github.com/cicybot/electron-mcp.git ~/mcp
fi

cd /root/mcp
npm install
npm install -g electron
grep -qxF "alias el='/root/.nvm/versions/node/v22.22.0/bin/electron'" ~/.bashrc || echo "alias el='/root/.nvm/versions/node/v22.22.0/bin/electron'" >> ~/.bashrc

touch /root/electron-mcp/token-dev.txt
touch /root/electron-mcp/menu.json
source ~/gcs-env.sh
cd /root/cicy-remote/colab
sh vnc-install.sh
cd ~/
ps aux | grep cloudflared
ps aux | grep jupyter
curl -iL http://localhost:8889/lab
curl http://localhost:6080
