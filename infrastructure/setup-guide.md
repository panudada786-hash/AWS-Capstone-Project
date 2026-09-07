# 🏗️ Infrastructure Setup Guide: Capstone Project 1
**Project:** Resilient, Scalable Web Application on AWS
**Goal:** Deploy a fault-tolerant, auto-scaling web environment using VPC, EFS, EC2, ALB, and Route 53.

> **⚠️ Prerequisites:**
> - An active AWS Account.
> - A registered domain name (optional, for Route 53).
> - AWS CLI installed (optional, for scripting).

---

## 📋 Phase 1: VPC & Network Design
*Goal: Create a secure, isolated network with Public and Private subnets across 2 Availability Zones.*

### 1. Create the VPC
1.  Navigate to **VPC Dashboard** > **Your VPCs** > **Create VPC**.
2.  **Name Tag:** `Capstone-VPC`
3.  **IPv4 CIDR Block:** `10.0.0.0/16`
4.  Click **Create VPC**.

### 2. Create Subnets (Multi-AZ)
*We need 4 subnets: 2 Public (for Load Balancer) and 2 Private (for Servers).*

1.  Go to **Subnets** > **Create Subnet**.
2.  **VPC:** Select `Capstone-VPC`.
3.  **Name Tag:** `Public-Subnet-A`
4.  **Availability Zone:** `us-east-1a` (or your default region's Zone A).
5.  **IPv4 CIDR:** `10.0.1.0/24`
6.  Click **Create**.
7.  **Repeat** for:
    - `Public-Subnet-B` (Zone B, CIDR `10.0.2.0/24`)
    - `Private-Subnet-A` (Zone A, CIDR `10.0.10.0/24`)
    - `Private-Subnet-B` (Zone B, CIDR `10.0.11.0/24`)

### 3. Create Internet Gateway & Route Tables
1.  Go to **Internet Gateways** > **Create Internet Gateway**. Name: `Capstone-IGW`. Attach it to `Capstone-VPC`.
2.  **Route Tables:**
    - Create `RT-Public`. Add a Route: `0.0.0.0/0` -> `Internet Gateway`.
    - **Subnet Associations:** Associate `Public-Subnet-A` and `Public-Subnet-B`.
    - Create `RT-Private`. **Do not** add a default route (keep it private). Associate `Private-Subnet-A` and `Private-Subnet-B`.

---

## 🔐 Phase 2: Security Groups
*Goal: Restrict access so only the Load Balancer can talk to servers.*

1.  **Create Security Group `SG-ALB`:**
    - **Inbound Rules:**
        - Type: `HTTP` (80), Source: `0.0.0.0/0`
        - Type: `HTTPS` (443), Source: `0.0.0.0/0`
2.  **Create Security Group `SG-EC2`:**
    - **Inbound Rules:**
        - Type: `HTTP` (80), Source: `SG-ALB` (Select the group ID, not IP).
    - **Outbound Rules:** Allow all traffic.

---

## 📦 Phase 3: Shared Storage (EFS)
*Goal: Create a shared file system accessible by all servers.*

1.  Go to **EFS** > **Create File System**.
2.  **Name:** `Capstone-EFS`.
3.  **Performance Mode:** `General Purpose`.
4.  **Throughput Mode:** `Bursting`.
5.  **Encryption:** Enabled.
6.  **Create** the file system.
7.  **Add Mount Targets:**
    - Select **Private-Subnet-A** and **Private-Subnet-B**.
    - Assign them to `SG-EC2`.
    - Click **Create mount targets**.

---

## 💻 Phase 4: Custom AMI (Golden Image)
*Goal: Create a pre-configured server image with the web app ready to go.*

1.  **Launch a Temporary EC2:**
    - **AMI:** Amazon Linux 2 (or Ubuntu).
    - **Instance Type:** `t2.micro`.
    - **Network:** Select `Capstone-VPC` -> `Public-Subnet-A`.
    - **Security Group:** Select `SG-ALB` (temporarily) to access via SSH.
    - **Configure:** Click "Edit" under "Advanced Details" (or skip for now).
2.  **Connect & Configure:**
    ```bash
    # Install Web Server
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    
    # Install EFS Tools
    sudo yum install -y amazon-efs-utils
    
    # Mount EFS (Replace fs-xxxx with your EFS ID)
    sudo mkdir /var/www/html/shared
    sudo mount -t efs -o tls fs-0123456789abcdef0:/ /var/www/html/shared
    
    # Put a test file
    echo "<h1>Capstone Project 1: Success!</h1>" > /var/www/html/index.html
    ```
3.  **Create AMI:**
    - Go to **EC2 Console** > **Instances** -> Select your instance.
    - Actions -> **Image and templates** -> **Create image**.
    - **Name:** `Capstone-AMI-v1`.
    - Click **Create Image**.

---

## ⚖️ Phase 5: Auto Scaling Group (ASG)
*Goal: Automate scaling and health checks.*

1.  **Create Launch Template:**
    - Name: `Capstone-Launch-Tmpl`.
    - **AMI:** Select `Capstone-AMI-v1`.
    - **Instance Type:** `t2.micro`.
    - **Network:** `Capstone-VPC`, Private Subnets.
    - **Security Group:** `SG-EC2`.
    - **User Data:** (Optional) Paste content from `scripts/user-data.sh` (see `README` section).
2.  **Create Auto Scaling Group:**
    - Name: `Capstone-ASG`.
    - **Launch Template:** Select `Capstone-Launch-Tmpl`.
    - **Subnets:** Select `Private-Subnet-A` and `Private-Subnet-B`.
    - **Scaling Policies:**
        - **Desired Capacity:** 2
        - **Min Capacity:** 1
        - **Max Capacity:** 4
    - **Health Check:** EC2.
    - **Load Balancing:** Select **Application Load Balancer** (create one in next step).

---

## 🔄 Phase 6: Application Load Balancer (ALB)
*Goal: Distribute traffic and perform health checks.*

1.  **Create Target Group:**
    - Name: `Capstone-TG`.
    - **Target Type:** Instances.
    - **Protocol:** HTTP (Port 80).
    - **Health Check Path:** `/`.
    - **Create**.
2.  **Create Load Balancer:**
    - Name: `Capstone-ALB`.
    - **Scheme:** Internet-facing.
    - **Network Mapping:** Select `Public-Subnet-A` and `Public-Subnet-B`.
    - **Security Group:** Select `SG-ALB`.
    - **Listeners:** HTTP:80.
    - **Default Action:** Forward to `Capstone-TG`.

---

## 🌐 Phase 7: DNS (Route 53)
*Goal: Map a domain name to the Load Balancer.*

1.  Go to **Route 53** > **Hosted Zones** > **Create Hosted Zone**.
2.  **Domain Name:** `yourdomain.com`.
3.  **Create Record:**
    - **Record Name:** `www` (or leave blank for root).
    - **Record Type:** `A`.
    - **Alias:** `True`.
    - **Target:** Select your `Capstone-ALB` from the list.
4.  **Update DNS:** Go to your domain registrar (GoDaddy, Namecheap, etc.) and update the **Name Servers (NS)** to the values provided in the Route 53 Hosted Zone.

---

## ✅ Verification Steps
1.  **Check ASG:** Ensure 2 instances are running and healthy.
2.  **Check ALB:** Go to Target Groups -> View Targets -> Ensure status is "Healthy".
3.  **Test Load:** Open your domain in a browser. You should see "Capstone Project 1: Success!".
4.  **Test Failover:** Go to EC2 -> Terminate one instance. Watch Auto Scaling launch a new one automatically.

---
*Generated for Capstone Project 1 Implementation.*