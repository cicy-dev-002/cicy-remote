if [ ! -d "/content/cloudflare-python-workers" ]; then
    echo "Cloning cloudflare-python-workers..."
    git clone https://github.com/cicybot/cloudflare-python-workers.git /content/cloudflare-python-workers
    cd /content/cloudflare-python-workers
else
    cd /content/cloudflare-python-workers
    git pull origin main
    ls -alh
fi
cd workers
export API_URL=https://mac-8989.cicy.de5.net
#
#uv sync
#pkill worker.py
#nohup uv run worker.py colab_1001  > /content/workers.log 2>&1 &
#sleep 1
#cat /content/workers.log
