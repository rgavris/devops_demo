#!/bin/bash

# Script to check droplet status and troubleshoot

DROPLET_IP=$(cd ~/devops_demo && terraform output -raw server_ip 2>/dev/null)

if [ -z "$DROPLET_IP" ]; then
    echo "Error: Could not get droplet IP from Terraform"
    exit 1
fi

echo "========================================="
echo "Droplet Status Check"
echo "========================================="
echo "IP Address: $DROPLET_IP"
echo ""

echo "1. Testing connectivity..."
if ping -c 1 -W 2 $DROPLET_IP > /dev/null 2>&1; then
    echo "   ✓ Server is reachable"
else
    echo "   ✗ Server is not reachable"
    exit 1
fi

echo ""
echo "2. Testing HTTP endpoints..."
echo "   Testing port 80 (Nginx)..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://$DROPLET_IP 2>/dev/null || echo "000")
if [ "$HTTP_STATUS" != "000" ] && [ "$HTTP_STATUS" != "" ]; then
    echo "   ✓ Port 80 responding (HTTP $HTTP_STATUS)"
else
    echo "   ✗ Port 80 not responding"
fi

echo "   Testing port 3000 (Direct)..."
PORT3000_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://$DROPLET_IP:3000 2>/dev/null || echo "000")
if [ "$PORT3000_STATUS" != "000" ] && [ "$PORT3000_STATUS" != "" ]; then
    echo "   ✓ Port 3000 responding (HTTP $PORT3000_STATUS)"
else
    echo "   ✗ Port 3000 not responding"
fi

echo ""
echo "3. To SSH into the droplet and check status:"
echo "   ssh root@$DROPLET_IP"
echo ""
echo "4. Once SSH'd in, check:"
echo "   - Setup script logs: tail -f /var/log/cloud-init-output.log"
echo "   - PM2 status: pm2 status"
echo "   - Application logs: pm2 logs life-schedule"
echo "   - Nginx status: sudo systemctl status nginx"
echo "   - PostgreSQL status: sudo systemctl status postgresql"
echo "   - Firewall status: sudo ufw status"
echo ""
echo "========================================="


