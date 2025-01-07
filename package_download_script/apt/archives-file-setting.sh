#!/bin/bash

# Usage: ./script.sh <remote_user> <remote_host>

REMOTE_USER=$1
REMOTE_HOST=$2
LOCAL_ARCHIVES="archives"
LOCAL_SCRIPT="apt-get-install-with-version.sh"
REMOTE_ARCHIVES_DIR="/root/archives"
REMOTE_SCRIPT="/root/apt-get-install-with-version.sh"

if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_HOST" ]; then
  echo "Usage: $0 <remote_user> <remote_host>"
  exit 1
fi

# Check if local files exist
if [ ! -e "$LOCAL_ARCHIVES" ]; then
  echo "Error: $LOCAL_ARCHIVES does not exist in the current directory."
  exit 1
fi

if [ ! -e "$LOCAL_SCRIPT" ]; then
  echo "Error: $LOCAL_SCRIPT does not exist in the current directory."
  exit 1
fi

# Copy files to remote server
scp -r "$LOCAL_ARCHIVES" "$REMOTE_USER@$REMOTE_HOST:/root/archives"
scp "$LOCAL_SCRIPT" "$REMOTE_USER@$REMOTE_HOST:/root/apt-get-install-with-version.sh"

# Execute commands on the remote server via SSH
ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
  set -e

  # Move archives to /usr/local/archives
  sudo mv /root/archives /usr/local/archives

  # Change ownership of the archives directory
  sudo chown -R _apt: /usr/local/archives

  # Update sources.list to include the local archives
  echo "deb [trusted=yes] file:/usr/local/archives ./" | sudo tee /etc/apt/sources.list

  echo "Setup completed on $REMOTE_HOST"
EOF
