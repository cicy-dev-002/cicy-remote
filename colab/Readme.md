if [ ! -d "cicy-remote" ]; then
    echo "Cloning cicy-remote..."
    git clone https://github.com/cicybot/cicy-remote.git
else
    cd cicy-remote
    git pull origin main
fi