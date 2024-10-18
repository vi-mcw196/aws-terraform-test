#!/bin/bash

# Test User Data Script

# Variables
GITHUB_TOKEN="${github_token}"

# Wait for the build to complete
while true; do
  # Check if the release is available
  RELEASE_COUNT=$(gh release list | wc -l)
  if [ "$RELEASE_COUNT" -gt 0 ]; then
    echo "Release found. Proceeding with installation."
    break
  else
    echo "No release found. Waiting..."
    sleep 30
  fi
done

# Update and install dependencies
apt-get update -y
apt-get install -y git python3-pip

# Install GitHub CLI
apt-get install -y curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" > \
  /etc/apt/sources.list.d/github-cli.list
apt-get update -y
apt-get install -y gh

# Authenticate GitHub CLI
echo "${GITHUB_TOKEN}" | gh auth login --with-token

# Get the latest release asset URL
ASSET_URL=$(gh release view --json assets -q '.assets[0].url')

# Download the asset
curl -L -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/octet-stream" "$ASSET_URL" -o app.whl

# Install the application
pip3 install app.whl

# Create a systemd service file
cat <<EOL > /etc/systemd/system/myapp.service
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
systemctl daemon-reload
systemctl enable myapp.service
systemctl start myapp.service

# Perform smoke test after a delay to ensure the app is running
sleep 10

# Smoke Test
URL="http://localhost:5000/"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "$HTTP_CODE" -eq 200 ]; then
  echo "Smoke test passed: Application is running."
else
  echo "Smoke test failed: Application is not running."
  exit 1
fi
