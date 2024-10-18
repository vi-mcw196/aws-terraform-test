#!/bin/bash

# install.sh

# Variables
INSTALL_DIR="/opt/myapp"

# Navigate to home directory
cd /home/ubuntu

# Update and install dependencies
sudo apt-get update -y
sudo apt-get install -y git python3-pip

# Install GitHub CLI
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
sudo apt update -y
sudo apt install gh -y

# Authenticate GitHub CLI
echo "${GITHUB_TOKEN}" | gh auth login --with-token

# Get the latest release asset URL
ASSET_URL=$(gh release view --json assets -q '.assets[0].url')

# Download the asset
curl -L -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/octet-stream" "$ASSET_URL" -o app.whl

# Install the application
pip3 install --user app.whl

# Create a systemd service file
sudo tee /etc/systemd/system/myapp.service > /dev/null <<EOL
[Unit]
Description=My Flask App

[Service]
ExecStart=/usr/bin/python3 -m my_flask_app
Restart=always
User=ubuntu
Environment=PYTHONUNBUFFERED=1
Environment=PATH=/usr/bin:/usr/local/bin:/home/ubuntu/.local/bin

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl enable myapp.service
sudo systemctl start myapp.service
