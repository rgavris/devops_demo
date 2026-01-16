# Life Schedule App - DevOps Setup

This directory contains Terraform configuration and setup scripts to deploy the life-schedule app on a DigitalOcean droplet.

## Files

- `main.tf` - Terraform configuration for creating a DigitalOcean droplet
- `variables.tf` - Terraform variable definitions
- `setup_life_schedule.sh` - Automated setup script that runs on droplet creation
- `terraform.tfvars` - Your DigitalOcean API token (not committed to git)

## Prerequisites

1. Terraform installed
2. DigitalOcean API token
3. SSH key added to DigitalOcean

## Setup Instructions

### 1. Configure Terraform Variables

Create or update `terraform.tfvars` with your DigitalOcean API token:

```hcl
do_token = "your-digitalocean-api-token-here"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan the Deployment

```bash
terraform plan
```

### 4. Apply the Configuration

```bash
terraform apply
```

This will:
- Create a new Ubuntu 22.04 droplet
- Automatically run the setup script (`setup_life_schedule.sh`) via user_data
- Install all dependencies (Node.js, PostgreSQL, PM2, Nginx)
- Clone the life-schedule repository
- Set up the database
- Build and start the application
- Configure Nginx as a reverse proxy

### 5. Access Your Application

After the setup completes (usually 5-10 minutes), you can access:

- **Direct**: `http://<droplet-ip>:3000`
- **Via Nginx**: `http://<droplet-ip>`

Get the IP address from:
```bash
terraform output server_ip
```

## What the Setup Script Does

The `setup_life_schedule.sh` script automatically:

1. **Updates system packages**
2. **Installs dependencies**: curl, git, build-essential, PostgreSQL, Nginx
3. **Installs Node.js 20.x**
4. **Installs PM2** for process management
5. **Sets up PostgreSQL**:
   - Creates database user (matches system user)
   - Creates `life_schedule` database
   - Grants necessary permissions
6. **Clones the repository** from GitHub
7. **Installs npm dependencies**
8. **Builds the TypeScript project**
9. **Creates .env file** with generated secrets
10. **Starts the app with PM2**
11. **Configures Nginx** as reverse proxy
12. **Sets up firewall** rules

## Post-Deployment

### Check Application Status

SSH into your droplet:
```bash
ssh root@<droplet-ip>
```

View PM2 status:
```bash
pm2 status
pm2 logs life-schedule
```

### Restart Application

```bash
pm2 restart life-schedule
```

### Update Application

```bash
cd ~/life-schedule
git pull
npm install
npm run build
pm2 restart life-schedule
```

### View Logs

```bash
pm2 logs life-schedule
# or
tail -f ~/life-schedule/logs/out.log
```

## Environment Variables

The setup script creates a `.env` file in the application directory with:

- `NODE_ENV=production`
- `PORT=3000`
- `DB_USER` - PostgreSQL user (matches system user)
- `DB_PASSWORD` - Auto-generated secure password
- `DB_HOST=localhost`
- `DB_PORT=5432`
- `DB_NAME=life_schedule`
- `JWT_SECRET` - Auto-generated secure secret

**Important**: Update the database password in `.env` if you need to change it.

## Security Notes

- The setup script generates secure random passwords
- Firewall is configured to only allow necessary ports
- Nginx is set up as a reverse proxy
- Consider setting up SSL/TLS with Let's Encrypt for production

## Troubleshooting

### Application not starting

1. Check PM2 status: `pm2 status`
2. Check logs: `pm2 logs life-schedule`
3. Verify database connection: `sudo -u postgres psql -c "\l"`
4. Check if port 3000 is in use: `sudo lsof -i :3000`

### Database connection issues

1. Verify PostgreSQL is running: `sudo systemctl status postgresql`
2. Check database exists: `sudo -u postgres psql -c "\l"`
3. Verify user permissions: `sudo -u postgres psql -c "\du"`

### Nginx issues

1. Check Nginx status: `sudo systemctl status nginx`
2. Test configuration: `sudo nginx -t`
3. Check error logs: `sudo tail -f /var/log/nginx/error.log`

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

This will delete the droplet and all associated resources.


