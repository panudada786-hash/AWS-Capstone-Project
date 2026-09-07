🏗️ Capstone Project 1 — AWS Infrastructure Setup Guide
Resilient, Scalable Web Application on AWS
This guide provides step-by-step instructions for deploying a resilient and scalable web application on AWS using:

Amazon VPC
Public and Private Subnets
Internet Gateway
Security Groups
Amazon EFS
Amazon EC2
Custom AMI
Auto Scaling Group
Application Load Balancer
Amazon Route 53
📋 Prerequisites
Before starting, make sure you have:

An active AWS account
A registered domain name (optional)
AWS CLI installed (optional)
An SSH key pair for EC2 access
Basic knowledge of AWS
Note: Replace example values such as Availability Zones, EFS IDs, AMI IDs, and domain names with the values from your AWS environment.

🏗️ Architecture
                         Internet
                            |
                            v
                     +-------------+
                     |  Route 53   |
                     |     DNS     |
                     +------+------+
                            |
                            v
                 +---------------------+
                 | Application Load    |
                 | Balancer (ALB)      |
                 +----------+----------+
                            |
                +-----------+-----------+
                |                       |
                v                       v
        +---------------+       +---------------+
        | Private AZ-A  |       | Private AZ-B  |
        |               |       |               |
        |    EC2-A      |       |    EC2-B      |
        +-------+-------+       +-------+-------+
                |                       |
                +-----------+-----------+
                            |
                            v
                     +-------------+
                     |     EFS     |
                     +-------------+

                    Capstone-VPC

The ALB is deployed in public subnets, while the application servers run in private subnets.

Phase 1: VPC & Network Design
1. Create the VPC
Navigate to:

AWS Console → VPC → Your VPCs → Create VPC

Configure:

Setting	Value
Name	Capstone-VPC
IPv4 CIDR	10.0.0.0/16
IPv6	Disabled
Tenancy	Default

Click Create VPC.

2. Create Subnets
Create four subnets across two Availability Zones.

Public Subnets
Name	Availability Zone	CIDR
Public-Subnet-A	us-east-1a	10.0.1.0/24
Public-Subnet-B	us-east-1b	10.0.2.0/24

Private Subnets
Name	Availability Zone	CIDR
Private-Subnet-A	us-east-1a	10.0.10.0/24
Private-Subnet-B	us-east-1b	10.0.11.0/24

Use Availability Zones available in your selected AWS region.

3. Create Internet Gateway
Navigate to:

VPC → Internet Gateways → Create Internet Gateway

Set:

Name: Capstone-IGW

After creating it:

Select Capstone-IGW.
Select Actions → Attach to VPC.
Select Capstone-VPC.
Click Attach.
4. Create Public Route Table
Navigate to:

VPC → Route Tables → Create Route Table

Configure:

Name: RT-Public
VPC: Capstone-VPC

Add this route:

Destination	Target
10.0.0.0/16	Local
0.0.0.0/0	Capstone-IGW

Associate the route table with:

Public-Subnet-A
Public-Subnet-B
5. Create Private Route Table
Create another route table:

Name: RT-Private
VPC: Capstone-VPC

Associate it with:

Private-Subnet-A
Private-Subnet-B
The private route table should not contain a direct route to the Internet Gateway.

Important: If private EC2 instances need outbound internet access for package installation or updates, configure a NAT Gateway. NAT Gateways create additional AWS charges.

Phase 2: Security Groups
1. Create ALB Security Group
Navigate to:

VPC → Security Groups → Create Security Group

Configure:

Name: SG-ALB
Description: Security group for Application Load Balancer
VPC: Capstone-VPC

Inbound Rules
Type	Port	Source
HTTP	80	0.0.0.0/0
HTTPS	443	0.0.0.0/0

Outbound Rules
Allow all outbound traffic.

2. Create EC2 Security Group
Configure:

Name: SG-EC2
Description: Security group for application servers
VPC: Capstone-VPC

Inbound Rules
Type	Port	Source
HTTP	80	SG-ALB

The source should be the security group reference, not an IP address.

Outbound Rules
Allow all outbound traffic.

Security Flow
Internet
   |
   v
SG-ALB
HTTP/HTTPS
   |
   v
SG-EC2
HTTP:80

This prevents direct HTTP access to the EC2 instances from the internet.

Phase 3: Shared Storage — Amazon EFS
1. Create EFS
Navigate to:

AWS Console → EFS → Create file system

Configure:

Name: Capstone-EFS
Performance Mode: General Purpose
Throughput Mode: Bursting
Encryption: Enabled

Create the file system.

2. Create EFS Mount Targets
Create mount targets in both private subnets.

Mount Target	Subnet	Security Group
Mount Target A	Private-Subnet-A	SG-EC2
Mount Target B	Private-Subnet-B	SG-EC2

Important: EFS uses NFS on port 2049. Make sure your security configuration allows NFS traffic between the EC2 instances and EFS.

For a production setup, a separate EFS security group is recommended.

Phase 4: Create the Golden AMI
The Golden AMI contains the web server and application configuration.

1. Launch Temporary EC2 Instance
Navigate to:

EC2 → Instances → Launch Instance

Configure:

Setting	Value
Name	Capstone-AMI-Builder
AMI	Amazon Linux 2
Instance Type	t2.micro
VPC	Capstone-VPC
Subnet	Public-Subnet-A

For the temporary instance, use a temporary security group that allows SSH only from your IP address.

Do not use SG-ALB for SSH.

2. Install Apache
Connect to the temporary EC2 instance.

Run:

sudo yum update -y
sudo yum install -y httpd

Start Apache:

sudo systemctl start httpd
sudo systemctl enable httpd

Check the service:

sudo systemctl status httpd

3. Install EFS Utilities
Run:

sudo yum install -y amazon-efs-utils

Create the mount directory:

sudo mkdir -p /var/www/html/shared

Mount EFS:

sudo mount -t efs -o tls fs-XXXXXXXX:/ /var/www/html/shared

Replace:

fs-XXXXXXXX

with your actual EFS File System ID.

Verify:

df -h

4. Create Test Web Page
Run:

echo "<h1>Capstone Project 1: Success!</h1>" | sudo tee /var/www/html/index.html

Test Apache:

curl http://localhost

Expected output:

<h1>Capstone Project 1: Success!</h1>

5. Create the AMI
After configuring the instance:

Go to EC2 → Instances.
Select Capstone-AMI-Builder.
Select Actions.
Select Image and templates → Create image.
Set:
Name: Capstone-AMI-v1

Click Create image.
Wait until the AMI becomes available.
Phase 5: Create Launch Template
Navigate to:

EC2 → Launch Templates → Create launch template

Configure:

Name: Capstone-Launch-Tmpl
AMI: Capstone-AMI-v1
Instance Type: t2.micro
Security Group: SG-EC2

The application instances will be launched into the private subnets by the Auto Scaling Group.

Phase 6: Create Target Group
Navigate to:

EC2 → Target Groups → Create target group

Configure:

Setting	Value
Target Type	Instances
Name	Capstone-TG
Protocol	HTTP
Port	80
VPC	Capstone-VPC
Health Check Protocol	HTTP
Health Check Path	/

Create the target group.

Phase 7: Create Application Load Balancer
Navigate to:

EC2 → Load Balancers → Create Load Balancer

Select:

Application Load Balancer

Configure:

Name: Capstone-ALB
Scheme: Internet-facing
IP Address Type: IPv4

Network Mapping
Select:

VPC: Capstone-VPC

Availability Zone A:
Public-Subnet-A

Availability Zone B:
Public-Subnet-B

Security Group
Select:

SG-ALB

Listener
Configure:

Protocol: HTTP
Port: 80
Default Action: Forward to Capstone-TG

Traffic flow:

Internet
    |
    v
Capstone-ALB
    |
    v
Capstone-TG
    |
    +----------+
    |          |
    v          v
  EC2-A      EC2-B

Phase 8: Create Auto Scaling Group
Navigate to:

EC2 → Auto Scaling Groups → Create Auto Scaling Group

Configure:

Name: Capstone-ASG
Launch Template: Capstone-Launch-Tmpl

Select:

Private-Subnet-A
Private-Subnet-B

Capacity
Setting	Value
Desired Capacity	2
Minimum Capacity	1
Maximum Capacity	4

Health Checks
Enable:

EC2 Health Check

Also configure ELB health checks so unhealthy application instances can be replaced appropriately.

Attach Target Group
Attach:

Capstone-TG

New EC2 instances launched by the Auto Scaling Group will automatically register with the target group.

Phase 9: Route 53 DNS
Route 53 allows a custom domain to point to the Application Load Balancer.

A custom domain is optional. You can test the application using the ALB DNS name.

1. Create Hosted Zone
Navigate to:

Route 53 → Hosted Zones → Create Hosted Zone

Configure:

Domain Name: yourdomain.com
Type: Public hosted zone

Create the hosted zone.

2. Create Alias Record
For the root domain:

Record Name: Leave blank
Record Type: A
Alias: Yes
Target: Capstone-ALB

For www:

Record Name: www
Record Type: A
Alias: Yes
Target: Capstone-ALB

3. Update Name Servers
If your domain is registered with another provider:

Open your Route 53 hosted zone.
Copy the AWS name servers.
Open your domain registrar.
Replace the existing name servers with the Route 53 name servers.
Save the changes.
Wait for DNS propagation.
Phase 10: Verification
1. Verify VPC
Confirm:

 Capstone-VPC exists.
 Two public subnets exist.
 Two private subnets exist.
 Internet Gateway is attached.
 Public route table is configured.
 Private route table is configured.
2. Verify Security Groups
SG-ALB
HTTP  : 80  → 0.0.0.0/0
HTTPS : 443 → 0.0.0.0/0

SG-EC2
HTTP : 80 → SG-ALB

EC2 instances should not have public HTTP access.

3. Verify EFS
Confirm:

 EFS file system exists.
 Encryption is enabled.
 Mount target exists in Private-Subnet-A.
 Mount target exists in Private-Subnet-B.
 NFS port 2049 is allowed.
4. Verify Auto Scaling Group
Navigate to:

EC2 → Auto Scaling Groups → Capstone-ASG

Expected:

Desired Capacity: 2
Minimum Capacity: 1
Maximum Capacity: 4

Two EC2 instances should be running.

5. Verify Target Group
Navigate to:

EC2 → Target Groups → Capstone-TG

Check the registered targets.

Expected:

Healthy

If the targets are unhealthy, check:

Apache is running.
Port 80 is open.
SG-EC2 allows traffic from SG-ALB.
Health check path / exists.
EC2 instances have the required application files.
Phase 11: Test the Application
Copy the DNS name of the Application Load Balancer.

It will look similar to:

http://Capstone-ALB-XXXXXXXX.us-east-1.elb.amazonaws.com

Open it in your browser.

Expected result:

Capstone Project 1: Success!

Phase 12: Test Auto Scaling & Failover
To test the resilience of the infrastructure:

Confirm two EC2 instances are running.
Confirm both targets are healthy.
Select one EC2 instance.
Terminate the instance.
Wait for the Auto Scaling Group to detect the reduced capacity.
A replacement EC2 instance should launch.
The new instance should automatically register with the target group.
Wait until the new target becomes healthy.
Expected behavior:

Before termination:

EC2-A → Healthy
EC2-B → Healthy

        ↓

Terminate EC2-A

        ↓

Auto Scaling detects reduced capacity

        ↓

New EC2 instance launched

        ↓

New instance registered with Target Group

        ↓

New instance → Healthy

