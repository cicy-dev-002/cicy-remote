while true; do
  if [ ! -f ~/running ]; then
    break
  fi
  echo "======================================================"
  ps aux | grep electron
  ps aux | grep jupyter
  ps aux | grep cloudflared
  docker ps
  netstat -tnlp
  sleep 10
done
