<img width="1917" height="1078" alt="Screenshot 2026-09-07 162349" src="https://github.com/user-attachments/assets/fffde957-f81d-4d73-b6d5-f35e5008a13d" />
# 🚀 Resilient & Scalable Web Application on AWS

**Capstone Project One** | *Cloud Infrastructure Deployment*  
**Author:** [Your Name]  
**Date:** September 7, 2026  


> This project demonstrates a **production-grade architecture** designed for **High Availability**, **Fault Tolerance**, and **Auto-Scaling** on AWS. It eliminates single points of failure using Multi-AZ deployments, Elastic Load Balancing, and shared storage.
>
> <img width="710" height="823" alt="Screenshot 2026-09-07 163016" src="https://github.com/user-attachments/assets/53976512-b1c2-4581-aef1-9a22889859f7" />


<img width="806" height="577" alt="Screenshot 2026-09-07 163041" src="https://github.com/user-attachments/assets/3ec63559-bee0-41a3-a47d-100a9eb6313a" />

*   **Public Subnets (Tier 1)**:
    *   Hosts the **Application Load Balancer (ALB)**.
    *   Contains **NAT Gateways** to allow private instances to reach the internet for updates.
    *   Accessible from the Internet via an Internet Gateway (IGW).
*   **Private Subnets (Tier 2)**:
    *   Hosts the **EC2 Instances** (Web Servers).
    *   **No direct internet access**: This ensures that if an attacker compromises a server, they cannot easily exfiltrate data or download malware directly.
    *   Distributed across **2+ Availability Zones (AZs)** for fault tolerance.
*   **Security Groups**:
    *   **ALB Security Group**: Allows HTTP/HTTPS (80/443) from `0.0.0.0/0`.
    *   **EC2 Security Group**: Allows traffic **only** from the ALB Security Group (not the public internet).
*   **EFS Mount Targets**:
    *   Located in each Private Subnet to ensure EC2 instances can mount the shared file system within the same AZ (reducing latency/cost).













<img width="1916" height="1078" alt="Screenshot 2026-09-07 162209" src="https://github.com/user-attachments/assets/1eb36814-b6c7-4398-8d28-6748b7ef1775" />
<img width="1917" height="1078" alt="Screenshot 2026-09-07 161919" src="https://github.com/user-attachments/assets/5d0faebe-8296-4187-82f5-452832453468" />
<img width="1917" height="1078" alt="Screenshot 2026-09-07 161703" src="https://github.com/user-attachments/assets/22bf0472-b0f8-4021-9f83-bbde51ae4108" />
<img width="1917" height="1078" alt="Screenshot 2026-09-07 162109" src="https://github.com/user-attachments/assets/fa81a5b5-e292-4456-b7d8-fdf7fcb24eb8" />
