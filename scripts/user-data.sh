#!/bin/bash
# ============================================================
# CAPSTONE PROJECT 1: EC2 User Data Script
# Purpose: Automate web server setup, EFS mounting, and app deployment
# ============================================================

set -e # Exit immediately if a command exits with a non-zero status

echo "Starting Capstone Project 1 Setup..."

# 1. Update System Packages
echo "[Step 1] Updating system packages..."
yum update -y

# 2. Install Web Server (Apache HTTPD)
echo "[Step 2] Installing Apache Web Server..."
yum install -y httpd

# 3. Install EFS Utilities (Required to mount the file system)
echo "[Step 3] Installing EFS utilities..."
yum install -y amazon-efs-utils

# 4. Configure the Web Application
echo "[Step 4] Configuring Web Application..."
cd /var/www/html

# Create a simple "Hello World" page to verify deployment
echo "<html>" > index.html
echo "<head><title>Capstone Project 1</title></head>" >> index.html
echo "<body>" >> index.html
echo "<h1 style='color: green;'>🚀 Success! Web App is Live</h1>" >> index.html
echo "<p>Deployed via Auto Scaling Group & EFS</p>" >> index.html
echo "<p>Instance ID: <strong>$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</strong></p>" >> html
echo "</body>" >> index.html
echo "</html>"

# 5. Mount the EFS File System
echo "[Step 5] Mounting EFS Shared Storage..."

# Define Mount Point
MOUNT_POINT="/var/www/html/shared"
mkdir -p $MOUNT_POINT

# REPLACE THIS with your actual EFS File System ID
# You can find this in the AWS Console under EFS -> File Systems
EFS_ID="fs-0123456789abcdef0" 
EFS_MOUNT_NAME="fs-0123456789abcdef0.efs.us-east-1.amazonaws.com"

# Mount the EFS (using TLS for security)
mount -t efs -o tls $EFS_MOUNT_NAME:$MOUNT_POINT

# Verify Mount (Optional: Check if it worked)
df -h | grep efs

# 6. Start and Enable the Web Server
echo "[Step 6] Starting Apache Web Server..."
systemctl start httpd
systemctl enable httpd

# 7. Create a Health Check Endpoint
# This allows the Load Balancer to verify the server is healthy
echo "[Step 7] Creating Health Check Endpoint..."
echo "Health Check OK - $(date)" > /var/www/html/health

# 8. Configure Security Groups (If running locally via cloud-init)
# Note: This is usually handled by the Launch Template/Security Group settings
# but we ensure the service is listening on port 80
echo "[Step 8] Verifying Port 80 is open..."
firewall-cmd --zone=public --add-service=http --permanent 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true

echo "============================================================"
echo "✅ Capstone Project 1 Setup Complete!"
echo "   - Web Server: Running"
echo "   - EFS Mounted: $MOUNT_POINT"
echo "   - App URL: http://localhost/"
echo "   - Health Check: http://localhost/health"
echo "============================================================"