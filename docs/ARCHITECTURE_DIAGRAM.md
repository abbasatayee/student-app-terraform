# Architecture Diagram - Step by Step Guide

This document provides step-by-step instructions to create a detailed architecture diagram for your AWS infrastructure presentation.

## Architecture Overview

Your infrastructure consists of:

- **VPC** with public and private subnets across 2 Availability Zones
- **Application Load Balancer** in public subnets
- **Auto Scaling Group** with EC2 instances in private subnets
- **RDS MySQL** database in private subnets (Multi-AZ)
- **Security Groups** for network isolation
- **IAM Roles** for secure access
- **Secrets Manager** for credential storage

## Step-by-Step: Creating the Diagram

### Option 1: Using Draw.io (Recommended for Presentations)

#### Step 1: Setup Draw.io

1. Go to https://app.diagrams.net/ (or use desktop app)
2. Create a new diagram
3. Choose "Blank Diagram"
4. Set canvas size: 1920x1080 (or your presentation size)

#### Step 2: Add AWS Icons

1. Click "More Shapes" (bottom left)
2. Enable "AWS19" or "AWS18" icon set
3. Click "Apply"

#### Step 3: Create the Base Structure

**A. Draw VPC Container**

- Drag "VPC" icon to canvas
- Label: "Student Web App VPC (10.0.0.0/16)"
- Size: Large rectangle covering most of canvas
- Color: Light blue (#E3F2FD)

**B. Add Availability Zones**

- Draw 2 vertical rectangles inside VPC
- Label: "Availability Zone 1 (us-east-1a)" and "Availability Zone 2 (us-east-1b)"
- Position: Side by side
- Color: Very light blue (#F5F5F5)

#### Step 4: Add Public Subnets

**In AZ 1:**

- Drag "Subnet" icon
- Label: "Public Subnet 1 (10.0.1.0/24)"
- Position: Top of AZ 1
- Color: Light green (#C8E6C9)

**In AZ 2:**

- Drag "Subnet" icon
- Label: "Public Subnet 2 (10.0.2.0/24)"
- Position: Top of AZ 2
- Color: Light green (#C8E6C9)

#### Step 5: Add Private Subnets

**In AZ 1:**

- Drag "Subnet" icon
- Label: "Private Subnet 1 (10.0.101.0/24)"
- Position: Bottom of AZ 1
- Color: Light orange (#FFE0B2)

**In AZ 2:**

- Drag "Subnet" icon
- Label: "Private Subnet 2 (10.0.102.0/24)"
- Position: Bottom of AZ 2
- Color: Light orange (#FFE0B2)

#### Step 6: Add Internet Gateway

- Drag "Internet Gateway" icon
- Position: Above VPC, centered
- Label: "Internet Gateway"
- Draw connection line to VPC

#### Step 7: Add Application Load Balancer

- Drag "Application Load Balancer" icon
- Position: Spanning both public subnets
- Label: "Application Load Balancer (ALB)"
- Add text box: "Port: 80 (HTTP)"
- Color: Light purple (#E1BEE7)

#### Step 8: Add Target Group

- Drag "Target Group" icon
- Position: Below ALB, in public subnet area
- Label: "Target Group (Port 80)"
- Draw connection: ALB → Target Group

#### Step 9: Add Auto Scaling Group

- Draw a container/group box
- Label: "Auto Scaling Group (ASG)"
- Position: Spanning both private subnets
- Add text: "Min: 1, Max: 6, Desired: 2"

#### Step 10: Add EC2 Instances

- Drag "EC2 Instance" icon (x2)
- Position: One in each private subnet, inside ASG container
- Label each: "EC2 Instance (t3.micro)"
- Add text boxes:
  - "Ubuntu 22.04 LTS"
  - "Node.js Application"
  - "Port 80"
- Draw connections: Target Group → EC2 Instances

#### Step 11: Add RDS Database

- Drag "RDS MySQL" icon (x2)
- Position: One in each private subnet (bottom)
- Label: "RDS MySQL 8.0 (Primary)" and "RDS MySQL 8.0 (Standby)"
- Add text boxes:
  - "db.t3.micro"
  - "Multi-AZ"
  - "Port 3306"
- Draw connection between Primary and Standby (replication)
- Draw connections: EC2 Instances → RDS (database access)

#### Step 12: Add Security Groups

Create separate boxes for each:

**Load Balancer Security Group:**

- Position: Near ALB
- Label: "LB Security Group"
- Rules:
  - Inbound: HTTP (80) from 0.0.0.0/0
  - Inbound: HTTPS (443) from 0.0.0.0/0
  - Outbound: All traffic

**Web Server Security Group:**

- Position: Near EC2 instances
- Label: "Web Security Group"
- Rules:
  - Inbound: HTTP (80) from LB Security Group
  - Outbound: All traffic

**Database Security Group:**

- Position: Near RDS
- Label: "Database Security Group"
- Rules:
  - Inbound: MySQL (3306) from Web Security Group
  - Outbound: All traffic

#### Step 13: Add IAM Components

- Drag "IAM Role" icon
- Position: Outside VPC, top right
- Label: "EC2 IAM Role"
- Add text:
  - "AmazonSSMManagedInstanceCore"
  - "SecretsManagerReadWrite"
- Draw connection: IAM Role → EC2 Instances

#### Step 14: Add Secrets Manager

- Drag "Secrets Manager" icon
- Position: Outside VPC, top left
- Label: "AWS Secrets Manager"
- Add text: "Secret: Mydbsecret"
- Draw connection: Secrets Manager → EC2 Instances (dashed line for access)

#### Step 15: Add Route Tables

- Draw "Route Table" icon (x1)
- Label: "Public Route Table"
- Routes:
  - 0.0.0.0/0 → Internet Gateway
- Position: Near public subnets
- Draw connections to public subnets

#### Step 16: Add Data Flow Arrows

**User Traffic Flow:**

1. Internet → Internet Gateway (thick blue arrow)
2. Internet Gateway → ALB (thick blue arrow)
3. ALB → Target Group (thick blue arrow)
4. Target Group → EC2 Instances (thick blue arrow)

**Database Access:**

- EC2 Instances → RDS Primary (green arrow, label: "MySQL 3306")
- RDS Primary ↔ RDS Standby (purple arrow, label: "Replication")

**Management Access:**

- IAM Role → EC2 (dashed line, label: "Permissions")
- Secrets Manager → EC2 (dashed line, label: "Credentials")

#### Step 17: Add Legend

Create a legend box in bottom right:

- Blue arrows: User traffic
- Green arrows: Database traffic
- Purple arrows: Replication
- Dashed lines: IAM/Management
- Colors:
  - Light Green: Public Subnets
  - Light Orange: Private Subnets
  - Light Blue: VPC

#### Step 18: Add Title and Metadata

- Title: "Student Web Application - AWS Infrastructure Architecture"
- Subtitle: "High Availability, Scalable, Secure"
- Add metadata box:
  - Region: us-east-1
  - Multi-AZ: Yes
  - Auto Scaling: Enabled
  - Encryption: Enabled

### Option 2: Using Mermaid (For Documentation)

I'll create a Mermaid diagram that you can use in Markdown or convert to image.

### Option 3: Using Lucidchart

Similar steps to Draw.io but with Lucidchart's interface.

## Detailed Component Specifications

### Network Layer

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**:
  - 10.0.1.0/24 (AZ 1)
  - 10.0.2.0/24 (AZ 2)
- **Private Subnets**:
  - 10.0.101.0/24 (AZ 1)
  - 10.0.102.0/24 (AZ 2)

### Compute Layer

- **Instance Type**: t3.micro
- **AMI**: Ubuntu 22.04 LTS
- **Auto Scaling**: Min 1, Max 6, Desired 2
- **Scaling Policy**: CPU-based (target: 80%)

### Database Layer

- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB
- **Multi-AZ**: Enabled
- **Backup**: 7-day retention

### Security

- **Security Groups**: 3 (LB, Web, Database)
- **IAM Role**: EC2 with SSM and Secrets Manager access
- **Encryption**: RDS storage encrypted

## Presentation Tips

1. **Use consistent colors** for each component type
2. **Label everything** clearly
3. **Show data flow** with arrows
4. **Group related components** visually
5. **Add callouts** for important features
6. **Include metrics** (availability, scalability numbers)
7. **Use icons** from AWS icon set for professional look
