#!/bin/bash

# This script automates the deployment process:
# 1. Applies the Terraform configuration.
# 2. Gets the IP of the new server.
# 3. Copies the setup script to the server.
# 4. Executes the setup script on the server via SSH.

set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Return the exit status of the last command in the pipe that failed

# --- Configuration ---
# The local path to the script you want to run on the remote server
LOCAL_SETUP_SCRIPT="setup_life_schedule.sh"
# The user to connect to the remote server with
REMOTE_USER="root"

# --- 1. Run Terraform ---
echo "🚀 Starting deployment..."
echo "[1/4] Applying Terraform configuration..."

# Run terraform apply and auto-approve the changes
if ! terraform apply -auto-approve; then
    echo "❌ Terraform apply failed. Aborting."
    exit 1
fi

echo "✅ Terraform apply successful."


# --- 2. Get Server IP ---
echo "[2/4] Retrieving server IP address..."

# Get the IP address from terraform output
DROPLET_IP=$(terraform output -raw server_ip)

if [ -z "$DROPLET_IP" ]; then
    echo "❌ Could not retrieve droplet IP address from Terraform output."
    exit 1
fi

echo "✅ Server IP found: $DROPLET_IP"


# --- 3. Upload Script ---
# The full path where the script will be placed on the remote server
REMOTE_SCRIPT_PATH="/$REMOTE_USER/$LOCAL_SETUP_SCRIPT"

echo "[3/4] Uploading setup script to the server..."

# Wait for the SSH service to be ready on the new server
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


# --- 4. Execute Script Remotely ---
echo "[4/4] Executing setup script on the server..."
echo "      You are now connected to the remote server. The setup script will run."
echo "      Output will be streamed below:"
echo "-----------------------------------------------------"

# Execute the script on the remote server via SSH.
# -t allocates a pseudo-terminal, which is often required for interactive scripts.
if ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t "$REMOTE_USER@$DROPLET_IP" "chmod +x $REMOTE_SCRIPT_PATH && $REMOTE_SCRIPT_PATH"; then
    echo "❌ Remote script execution failed."
    exit 1
fi

echo "-----------------------------------------------------"
echo "🎉 Deployment script finished successfully!"
echo "✅ Application should now be running on http://$DROPLET_IP"

