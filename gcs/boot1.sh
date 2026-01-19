
bash <(curl -fsSL https://raw.githubusercontent.com/cicybot/cloudflare-tunnel-proxy/refs/heads/main/install-cloudflared.sh)


sudo apt install fswatch cifs-utils smbclient -y
pip install jupyter

if [ ! -d ~/smb ]; then
  mkdir -p ~/smb
  chmod 777 ~/smb
fi

if [ ! -f ~/env.sh ]; then
  echo "CF_TUNNEL=" > ~/env.sh
fi
nohup cloudflared tunnel run --token "$CF_TUNNEL" > ~/tunnel.log 2>&1 &
nohup cloudflared access smb --hostname mac_smb_445.cicy.de5.net --url 127.0.0.1:4445 > ~/smb.log 2>&1 &

## jupyter
pkill -f jupyter

nohup jupyter lab \
  --ip=127.0.0.1 \
  --port=8888 \
  --ServerApp.allow_remote_access=True \
  --ServerApp.trust_xheaders=True \
  > ~/jupyter_lab.log 2>&1 &

## proxy
docker rm -f 3proxy
docker run --name 3proxy --rm -d -p "8082:3128/tcp" ghcr.io/tarampampam/3proxy:1

read -s -p "Enter smb Password: " pwd

echo
smbclient -L localhost -p 4445 -U ton --password="$pwd"

sudo mount -t cifs //127.0.0.1/smb ~/smb -o username=ton,password="$pwd",uid=1000,gid=1000,port=4445

## Check Status

ps aux | grep cloudflared
ps aux | grep jupyter
docker ps
ls -al ~/smb
