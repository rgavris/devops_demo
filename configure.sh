#!/bin/bash

# This script configures a server with the life-schedule application.
# It takes one argument: the IP address of the server to configure.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
LOCAL_SETUP_SCRIPT="setup_life_schedule.sh"
REMOTE_USER="root"

# --- Input Validation ---
if [ -z "$1" ]; then
    echo "❌ Error: No IP address provided."
    echo "Usage: ./configure.sh <server_ip_address>"
    exit 1
fi
DROPLET_IP=$1

echo "⚙️  Configuring server at $DROPLET_IP..."

# --- 1. Upload Script ---
REMOTE_SCRIPT_PATH="/$REMOTE_USER/$LOCAL_SETUP_SCRIPT"

echo "[1/2] Uploading setup script to the server..."

# Wait for the SSH service to be ready on the server
echo "      Waiting for SSH connection..."
while ! nc -z -w5 "$DROPLET_IP" 22; do
  echo "      SSH not available yet. Retrying in 5 seconds..."
  sleep 5
done
echo "      SSH is ready."

# Copy the setup script to the remote server
if ! scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOCAL_SETUP_SCRIPT" "$REMOTE_USER@$DROPLET_IP:$REMOTE_SCRIPT_PATH"; then
    echo "❌ Failed to upload setup script."
    exit 1
fi
echo "✅ Setup script uploaded successfully."

# --- 2. Execute Script Remotely ---
echo "[2/2] Executing setup script on the server..."
echo "-----------------------------------------------------"

# Execute the script on the remote server via SSH.
if ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t "$REMOTE_USER@$DROPLET_IP" "chmod +x $REMOTE_SCRIPT_PATH && $REMOTE_SCRIPT_PATH"; then
    echo "❌ Remote script execution failed."
    exit 1
fi

echo "-----------------------------------------------------"
echo "✅ Configuration script finished successfully!"

