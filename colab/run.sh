
if [ ! -d "/content/cloudflare-python-workers" ]; then
    echo "Cloning cloudflare-python-workers..."
    git clone https://github.com/cicybot/cloudflare-python-workers.git /content/cloudflare-python-workers
else
    cd /content/cloudflare-python-workers
    git pull origin main
fi
cd /content/cloudflare-python-workers/workers
uv sync