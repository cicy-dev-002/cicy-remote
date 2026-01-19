source ~/gcs-env.sh
## jupyter
pkill -f jupyter

nohup jupyter lab \
  --no-browser \
  --IdentityProvider.token=$JUPYTER_TOKEN \
  --ip=127.0.0.1 \
  --port=8888 \
  --ServerApp.allow_remote_access=True \
  --ServerApp.trust_xheaders=True \
  > ~/jupyter_lab.log 2>&1 &
