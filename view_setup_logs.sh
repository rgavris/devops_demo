#!/bin/bash

# Script to view setup logs from the droplet
# This uses DigitalOcean's console/API or you can SSH in

DROPLET_IP=$(cd ~/devops_demo && terraform output -raw server_ip 2>/dev/null)

if [ -z "$DROPLET_IP" ]; then
    echo "Error: Could not get droplet IP"
    exit 1
fi

echo "========================================="
echo "Viewing Setup Logs"
echo "========================================="
echo "Droplet IP: $DROPLET_IP"
echo ""
echo "Option 1: SSH into the droplet and check logs:"
echo "  ssh root@$DROPLET_IP"
echo "  Then run: tail -f /var/log/cloud-init-output.log"
echo ""
echo "Option 2: Check if setup is still running:"
echo "  ssh root@$DROPLET_IP 'ps aux | grep -E \"(setup|cloud-init)\"'"
echo ""
echo "Option 3: Check application status:"
echo "  ssh root@$DROPLET_IP 'pm2 status'"
echo "  ssh root@$DROPLET_IP 'pm2 logs life-schedule --lines 50'"
echo ""
echo "Option 4: Check if services are running:"
echo "  ssh root@$DROPLET_IP 'sudo systemctl status nginx postgresql'"
echo ""
echo "========================================="
echo ""
echo "If you don't have SSH access set up, you can:"
echo "1. Use DigitalOcean's web console (Access > Launch Droplet Console)"
echo "2. Add your SSH key to DigitalOcean and try again"
echo "3. Check the setup script might still be running (can take 5-10 minutes)"


