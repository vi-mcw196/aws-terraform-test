#!/bin/bash

# Test User Data Script

# Variables
GITHUB_TOKEN="${github_token}"
GITHUB_OWNER="${github_owner}"
GITHUB_REPO="${github_repo}"

# Update and install dependencies
apt-get update -y
apt-get install -y git python3-pip
pip3 install --upgrade importlib_metadata
pip3 install testresources

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
echo "${github_token}" | gh auth login --with-token

# Wait for the build to complete
MAX_WAIT_TIME=600  # Maximum wait time in seconds
WAIT_INTERVAL=30   # Wait interval in seconds
ELAPSED_TIME=0

while true; do
  # Check if the release is available
  RELEASE_COUNT=$(gh release list --repo "${github_owner}/${github_repo}" | wc -l)
  if [ "$RELEASE_COUNT" -gt 0 ]; then
    echo "Release found. Proceeding with installation."
    break
  else
    echo "No release found. Waiting..."
    sleep $WAIT_INTERVAL
    ELAPSED_TIME=$((ELAPSED_TIME + WAIT_INTERVAL))
    if [ "$ELAPSED_TIME" -ge "$MAX_WAIT_TIME" ]; then
      echo "Timeout reached. Exiting."
      exit 1
    fi
  fi
done

# Get the latest release asset URL
ASSET_URL=$(gh release view --repo "${github_owner}/${github_repo}" --json assets -q '.assets[0].url')

# Download the asset (the wheel file)
curl -L -H "Authorization: token ${github_token}" -H "Accept: application/octet-stream" "$ASSET_URL" -o my_flask_app-1.0.0-py3-none-any.whl

# Install the application (into the system Python environment)
pip3 install my_flask_app-1.0.0-py3-none-any.whl

# Create a systemd service file
cat <<EOL > /etc/systemd/system/myapp.service
[Unit]
Description=My Flask App
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/bin/python3 -m my_flask_app  # Run as a Python module
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start the service
systemctl daemon-reload
systemctl enable myapp.service
systemctl start myapp.service

# Perform smoke test after a delay to ensure the app is running
sleep 10

# Simple Smoke Test - Check if the service is reachable
curl http://localhost:5000/ && echo "Smoke test passed: Application is running." || echo "Smoke test failed: Application is not running."
