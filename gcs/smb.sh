#!/bin/bash
set -e

source ~/env.sh

SHARE_NAME="Share"
SHARE_DIR="/home/$(whoami)/Share"
SMB_CONF="/etc/samba/smb.conf"
SMB_USER="$(whoami)"
SMB_PASS="$JUPYTER_TOKEN"

echo "[+] Updating packages"
# sudo apt update -y
sudo apt install -y samba smbclient fswatch cifs-utils

echo "[+] Creating share directory"
mkdir -p "$SHARE_DIR"
chmod 0777 "$SHARE_DIR"

echo "[+] Backing up smb.conf (once)"
if [ ! -f /etc/samba/smb.conf1.backup ]; then
  sudo cp "$SMB_CONF" /etc/samba/smb.conf1.backup
fi

echo "[+] Configuring Samba share"
if ! grep -q "^\[$SHARE_NAME\]" "$SMB_CONF"; then
  sudo tee -a "$SMB_CONF" > /dev/null <<EOF

[$SHARE_NAME]
   path = $SHARE_DIR
   browseable = yes
   writable = yes
   guest ok = no
   public = yes
   create mask = 0777
   directory mask = 0777
EOF
else
  echo "    Share already exists, skip append"
fi

echo "[+] Configuring Samba user: $SMB_USER"

if ! id "$SMB_USER" &>/dev/null; then
  sudo useradd -m "$SMB_USER"
fi

(
  echo "$SMB_PASS"
  echo "$SMB_PASS"
) | sudo smbpasswd -a "$SMB_USER" >/dev/null 2>&1 || true

sudo smbpasswd -e "$SMB_USER"

echo "[+] Managing smbd service"

has_systemd() {
  pidof systemd >/dev/null 2>&1
}

smbd_running() {
  pgrep -x smbd >/dev/null 2>&1
}

if has_systemd; then
  if smbd_running; then
    sudo systemctl restart smbd || sudo systemctl restart samba
  else
    sudo systemctl start smbd || sudo systemctl start samba
  fi
else
  if smbd_running; then
    sudo pkill smbd || true
    sudo pkill nmbd || true
  fi
  sudo smbd -D
  sudo nmbd -D || true
fi

sleep 2

echo "[+] Samba status:"
ps aux | grep '[s]mbd' || true

IP=$(hostname -I | awk '{print $1}')

echo
echo "[+] Running smbclient check"

# --- SMBCLIENT CHECK ---
SMB_OK=true

echo "$SMB_PASS" | smbclient "//$IP/$SHARE_NAME" \
  -U "$SMB_USER" \
  -c 'ls' \
  >/tmp/smbclient_test.log 2>&1 || SMB_OK=false

if [ "$SMB_OK" = true ]; then
  echo "[✓] smbclient authentication OK"

  echo "$SMB_PASS" | smbclient "//$IP/$SHARE_NAME" \
    -U "$SMB_USER" \
    -c 'put /etc/hosts smb_test.txt' \
    >/dev/null 2>&1 && \
    echo "[✓] Write test OK (smb_test.txt)"
else
  echo "❌ smbclient FAILED"
  echo "---- smbclient output ----"
  cat /tmp/smbclient_test.log
  exit 1
fi

smbclient -L localhost -p 445 -U $SMB_USER

echo
echo "✅ SMB READY"
echo "   Server : //$IP/$SHARE_NAME"
echo "   User   : $SMB_USER"
echo "   Pass   : (hidden)"
