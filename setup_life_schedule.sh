#!/bin/bash

# Life Schedule App Setup Script
# This script sets up everything necessary to run the life-schedule app on a fresh Ubuntu droplet

set -e  # Exit on any error

echo "========================================="
echo "Life Schedule App Setup Script"
echo "========================================="

# Update system packages
echo "[1/8] Updating system packages..."

sudo -v

sudo apt-get update  -o DPkg::Lock::Timeout=300
sudo NEEDRESTART_MODE=n \
DEBIAN_FRONTEND=noninteractive \
apt-get upgrade -y \
-o DPkg::Lock::Timeout=300 \
-o Dpkg::Options::="--force-confdef" \
-o Dpkg::Options::="--force-confold"

# Install required system packages
echo "[2/8] Installing system dependencies..."
sudo apt-get install -y \
    curl \
    git \
    build-essential \
    postgresql \
    postgresql-contrib \
    ufw \
    nginx

# Install Node.js 20.x
echo "[3/8] Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installations
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# Install PM2 for process management
echo "[4/8] Installing PM2..."
sudo npm install -g pm2

# Set up PostgreSQL
echo "[5/8] Setting up PostgreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Get the current user (usually 'ubuntu' on DigitalOcean)
CURRENT_USER=$(whoami)
DB_USER=${DB_USER:-$CURRENT_USER}
DB_PASSWORD=${DB_PASSWORD:-$(openssl rand -base64 32)}

# Create PostgreSQL user and database
echo "Creating PostgreSQL user: $DB_USER"
sudo -u postgres psql << EOF
-- Create user (if not exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '$DB_USER') THEN
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
  END IF;
END
\$\$;

-- Create database
SELECT 'CREATE DATABASE life_schedule'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'life_schedule')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE life_schedule TO $DB_USER;
ALTER USER $DB_USER CREATEDB;
EOF

# Configure PostgreSQL to allow connections
echo "Configuring PostgreSQL..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" /etc/postgresql/*/main/postgresql.conf
sudo systemctl restart postgresql

# Clone the repository
echo "[6/8] Cloning life-schedule repository..."
APP_DIR="/home/$CURRENT_USER"
if [ "$CURRENT_USER" = "root" ]; then
    APP_DIR="/root"
fi
cd $APP_DIR
if [ -d "life-schedule" ]; then
    echo "Repository already exists, pulling latest changes..."
    cd life-schedule
    git pull
else
    git clone https://github.com/coyotespike/life-schedule.git
    cd life-schedule
fi

# Install npm dependencies
echo "[7/8] Installing npm dependencies..."
npm install

# Build the TypeScript project
echo "Building TypeScript project..."
npm run build

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << ENVEOF
NODE_ENV=production
PORT=3000
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=localhost
DB_PORT=5432
DB_NAME=life_schedule
JWT_SECRET=$(openssl rand -hex 32)
ENVEOF
fi

# Update server.ts to use environment variables (if needed)
# The script assumes the server.ts already supports DB_USER env var

# Set up PM2 ecosystem file
echo "Creating PM2 ecosystem file..."
cat > ecosystem.config.js << PM2EOF
module.exports = {
  apps: [{
    name: 'life-schedule',
    script: 'dist/index.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    max_memory_restart: '1G'
  }]
};
PM2EOF

# Create logs directory
mkdir -p logs

# Start the application with PM2
echo "[8/8] Starting application with PM2..."
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u $CURRENT_USER --hp $HOME

# Configure firewall
echo "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable

# Set up Nginx reverse proxy (optional but recommended)
echo "Setting up Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/life-schedule > /dev/null << NGINXEOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINXEOF

sudo ln -sf /etc/nginx/sites-available/life-schedule /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
sudo systemctl enable nginx

echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo "Application is running on:"
echo "  - Direct: http://$(curl -s ifconfig.me):3000"
echo "  - Via Nginx: http://$(curl -s ifconfig.me)"
echo ""
echo "PM2 Status:"
pm2 status
echo ""
echo "To view logs: pm2 logs life-schedule"
echo "To restart: pm2 restart life-schedule"
echo "To stop: pm2 stop life-schedule"
echo ""
echo "IMPORTANT: Update the PostgreSQL password in .env file!"
echo "========================================="

