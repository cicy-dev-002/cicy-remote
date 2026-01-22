# https://github.com/cicy-dev-002/cicy-remote.git
sudo apt install fswatch cifs-utils smbclient -y
sudo apt install python3-tk  python3-dev -y
pip install pyautogui pyperclip pillow pyscreeze
pip install jupyter jupyterlab
npm install -g electron

curl -fsSL https://opencode.ai/install | bash

if [ ! -f ~/gcs-env.sh ]; then
  echo "export CF_TUNNEL=" > ~/gcs-env.sh
  echo "export JUPYTER_TOKEN=" > ~/gcs-env.sh
fi

grep -qxF "source ~/gcs-env.sh'" ~/.bashrc || echo "source ~/gcs-env.sh" >> ~/.bashrc
grep -qxF "alias oc='~/.opencode/bin/opencode'" ~/.bashrc || echo "alias oc='~/.opencode/bin/opencode'" >> ~/.bashrc

source ~/.bashrc