#!/bin/bash

# Update package list
sudo apt update

# Install Samba
sudo apt install -y samba

# Create Share directory if it doesn't exist
mkdir -p ~/Share

# Backup original smb.conf
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Configure Samba share
sudo tee -a /etc/samba/smb.conf > /dev/null <<EOF
[Share]
   path = /home/$(whoami)/Share
   browseable = yes
   writable = yes
   guest ok = yes
   public = yes
EOF

# Restart Samba services
sudo systemctl restart smbd
sudo systemctl restart nmbd

echo "SMB server configured. Share accessible at //$(hostname -I | awk '{print $1}')/Share"