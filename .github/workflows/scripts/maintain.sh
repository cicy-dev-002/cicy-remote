while true; do
  echo "======================================================"
  ps aux | grep electron
  ps aux | grep jupyter
  ps aux | grep cloudflared
  docker ps
  netstat -tnlp
  sleep 10
  break
done
