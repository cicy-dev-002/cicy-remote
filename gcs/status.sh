docker ps
ps aux | grep cloudflare
ps aux | grep jupyter
ps aux | grep vnc

du -h --max-depth=2 /home 2>/dev/null | sort -hr | head -n 20
df -h