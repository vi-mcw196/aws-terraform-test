#!/bin/bash

# build.sh

# Variables
REPO_URL="https://${GITHUB_TOKEN}@github.com/pwr-twwo/lab3-grupa11-3.git"
APP_DIR="app"
BUILD_DIR="build"
RELEASE_NAME="v$(date +'%Y%m%d%H%M%S')"

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

# Clone the repository using HTTPS and token
git clone $REPO_URL $BUILD_DIR

# Navigate to app directory
cd $BUILD_DIR/$APP_DIR

# Install build tools
pip3 install --user --upgrade setuptools wheel
pip3 install -r requirements.txt

# Build the package
python3 setup.py sdist bdist_wheel

# Create a new release and upload the package
cd dist
PACKAGE_FILE=$(ls *.whl)

# Go back to repository root
cd ../../..

# Create a new release using GitHub CLI
gh release create $RELEASE_NAME "$BUILD_DIR/$APP_DIR/dist/$PACKAGE_FILE" --title "$RELEASE_NAME" --notes "Automated release $RELEASE_NAME"

# Clean up
rm -rf $BUILD_DIR
