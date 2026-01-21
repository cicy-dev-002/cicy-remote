# https://github.com/cicy-dev-002/cicy-remote.git
sudo apt install fswatch cifs-utils smbclient -y
pip install pyautogui pyperclip pillow pyscreeze
pip install jupyter jupyterlab

if [ ! -f ~/gcs-env.sh ]; then
  echo "export CF_TUNNEL=" > ~/gcs-env.sh
  echo "export JUPYTER_TOKEN=" > ~/gcs-env.sh
fi
grep -qxF "source ~/gcs-env.sh'" ~/.bashrc || echo "source ~/gcs-env.sh" >> ~/.bashrc
