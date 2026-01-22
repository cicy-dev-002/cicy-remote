#rm -rf /root/cloudflare-python-workers
if [ ! -d "/root/cloudflare-python-workers" ]; then
    echo "Cloning cloudflare-python-workers..."
    git clone https://$GH_CICYBOT_TOKEN@github.com/cicybot/cloudflare-python-workers.git /root/cloudflare-python-workers
    cd /root/cloudflare-python-workers
else
    cd /root/cloudflare-python-workers
    git pull origin main
fi
cd workers
export API_URL=https://mac-8988.cicy.de5.net
#
uv sync

WORKER_NAME="worker.py"
WORKER_ARG="colab_1001"

PID=$(ps aux | grep "$WORKER_NAME" | grep "$WORKER_ARG" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "=============>>>> worker.py not running, starting it..."
    nohup uv run worker.py colab_1001 > /root/workers.log 2>&1 &
    sleep 2
else
    echo "=============>>>> worker.py already running, PID=$PID"
fi

tail /root/workers.log
