#!/bin/bash

# This script provisions the infrastructure using Terraform and then
# automatically runs the configuration script on the new server.

set -e # Exit immediately if a command exits with a non-zero status.

# --- 1. Provision Infrastructure ---
echo "🚀 Starting Full Deployment..."
echo "[1/3] Initializing Terraform..."
terraform init

echo "[2/3] Applying Terraform configuration..."
if ! terraform apply -auto-approve; then
    echo "❌ Terraform apply failed. Aborting."
    exit 1
fi

# Get the IP address from terraform output
DROPLET_IP=$(terraform output -raw server_ip)

if [ -z "$DROPLET_IP" ]; then
    echo "❌ Could not retrieve server IP address from Terraform output."
    exit 1
fi

echo "✅ Infrastructure provisioned successfully. Server IP: $DROPLET_IP"

# --- 2. Run Configuration ---
echo "[3/3] Starting configuration of the new server..."

# Ensure configure.sh is executable before running it
if [ ! -x "./configure.sh" ]; then
    echo "      Making configure.sh executable..."
    chmod +x ./configure.sh
fi

./configure.sh "$DROPLET_IP"

echo
echo "🎉 Full deployment finished!"
echo "✅ Application should now be running on http://$DROPLET_IP"

