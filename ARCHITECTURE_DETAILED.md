# Detailed Architecture Diagram - Complete Guide

## Architecture Components Overview

### 1. Network Infrastructure

#### VPC (Virtual Private Cloud)

- **CIDR Block**: 10.0.0.0/16
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled
- **Purpose**: Isolated network environment for the application

#### Availability Zones

- **AZ 1**: us-east-1a
- **AZ 2**: us-east-1b
- **Purpose**: High availability and fault tolerance

#### Subnets

**Public Subnets** (Internet-facing):

- **Subnet 1**: 10.0.1.0/24 (AZ 1)
- **Subnet 2**: 10.0.2.0/24 (AZ 2)
- **Purpose**: Host Application Load Balancer
- **Auto-assign Public IP**: Enabled

**Private Subnets** (Internal):

- **Subnet 1**: 10.0.101.0/24 (AZ 1)
- **Subnet 2**: 10.0.102.0/24 (AZ 2)
- **Purpose**: Host EC2 instances and RDS database
- **Auto-assign Public IP**: Disabled

#### Internet Gateway

- **Purpose**: Provides internet access for public subnets
- **Connection**: Attached to VPC

#### Route Tables

- **Public Route Table**:
  - Default route: 0.0.0.0/0 → Internet Gateway
  - Associated with: Public Subnets
- **Private Route Table**:
  - No internet gateway route (instances use NAT if needed)

### 2. Load Balancing Layer

#### Application Load Balancer (ALB)

- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Subnets**: Public Subnet 1 & 2
- **Protocol**: HTTP (Port 80)
- **Features**:
  - Cross-zone load balancing: Enabled
  - HTTP/2: Enabled
  - Health checks: Enabled
  - Connection draining: 30 seconds

#### Target Group

- **Protocol**: HTTP
- **Port**: 80
- **Target Type**: Instance
- **Health Check**:
  - Path: /
  - Protocol: HTTP
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy threshold: 2
  - Unhealthy threshold: 2
  - Matcher: 200

### 3. Compute Layer

#### Auto Scaling Group (ASG)

- **Min Size**: 1 instance
- **Max Size**: 6 instances
- **Desired Capacity**: 2 instances
- **Subnets**: Private Subnet 1 & 2
- **Health Check Type**: ELB
- **Health Check Grace Period**: 120 seconds
- **Scaling Policy**: Target Tracking
  - Metric: Average CPU Utilization
  - Target Value: 80%

#### Launch Template

- **AMI**: Custom AMI (created from bootstrap instance)
- **Instance Type**: t3.micro
- **Key Pair**: webapp-key
- **IAM Profile**: EC2 instance profile
- **Security Group**: Web Security Group
- **Network**: Private subnets, no public IP

#### EC2 Instances

- **OS**: Ubuntu 22.04 LTS
- **Instance Type**: t3.micro
- **Application**: Node.js web application
- **Port**: 80
- **User Data**: Automated installation script
- **Distribution**: Across private subnets for high availability

### 4. Database Layer

#### RDS MySQL

- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB
- **Multi-AZ**: Enabled (High Availability)
- **Backup**:
  - Retention: 7 days
  - Window: 03:00-04:00 UTC
- **Maintenance Window**: Monday 04:00-05:00 UTC
- **Encryption**: Enabled
- **Subnets**: Private Subnet 1 & 2 (via DB Subnet Group)
- **Port**: 3306
- **Accessibility**: Not publicly accessible

#### DB Subnet Group

- **Subnets**: Private Subnet 1 & 2
- **Purpose**: Defines where RDS can be deployed

### 5. Security Layer

#### Security Groups

**Load Balancer Security Group**:

- **Inbound Rules**:
  - HTTP (80) from 0.0.0.0/0
  - HTTPS (443) from 0.0.0.0/0
- **Outbound Rules**:
  - All traffic to 0.0.0.0/0

**Web Server Security Group**:

- **Inbound Rules**:
  - HTTP (80) from Load Balancer Security Group only
- **Outbound Rules**:
  - All traffic to 0.0.0.0/0

**Database Security Group**:

- **Inbound Rules**:
  - MySQL (3306) from Web Server Security Group only
- **Outbound Rules**:
  - All traffic to 0.0.0.0/0

#### IAM Role

- **Name**: student-ec2-role
- **Policies**:
  - AmazonSSMManagedInstanceCore (SSM access)
  - SecretsManagerReadWrite (Secrets Manager access)
- **Attached to**: EC2 instances via instance profile

### 6. Secrets Management

#### AWS Secrets Manager

- **Secret Name**: Mydbsecret (fixed)
- **Contents**:
  - Database username
  - Database password
  - Database host (RDS endpoint)
  - Database port (3306)
  - Database name
- **Access**: EC2 instances via IAM role

### 7. Data Flow

#### User Request Flow

1. User → Internet Gateway (HTTP/HTTPS)
2. Internet Gateway → Application Load Balancer
3. ALB → Target Group (health check)
4. Target Group → EC2 Instance (HTTP 80)
5. EC2 Instance → RDS Database (MySQL 3306)
6. Response flows back through the same path

#### High Availability Flow

- **Load Distribution**: ALB distributes traffic across instances in both AZs
- **Database Replication**: Primary RDS in AZ1 replicates to Standby in AZ2
- **Auto Scaling**: ASG maintains desired capacity across AZs
- **Failover**: If AZ1 fails, traffic routes to AZ2 automatically

## Diagram Creation Tools

### Tool 1: Draw.io (Recommended)

- **URL**: https://app.diagrams.net/
- **Pros**: Free, professional, AWS icons available
- **Export**: PNG, PDF, SVG
- **Best for**: Presentations, documentation

### Tool 2: Lucidchart

- **URL**: https://www.lucidchart.com/
- **Pros**: Professional, collaboration features
- **Cons**: Paid (free tier limited)
- **Best for**: Team collaboration

### Tool 3: AWS Architecture Icons

- **URL**: https://aws.amazon.com/architecture/icons/
- **Format**: PNG, SVG
- **Use with**: Any diagramming tool
- **Best for**: Official AWS-style diagrams

### Tool 4: Mermaid (Code-based)

- **Format**: Markdown syntax
- **Pros**: Version controlled, easy to update
- **Cons**: Less visual control
- **Best for**: Documentation, README files

## Step-by-Step: Draw.io Instructions

### Phase 1: Setup (5 minutes)

1. Open https://app.diagrams.net/
2. Create new diagram
3. Enable AWS icons: More Shapes → AWS19 → Apply
4. Set page size: File → Page Setup → 1920x1080

### Phase 2: VPC Structure (10 minutes)

1. Draw large rectangle (VPC container)
2. Add title: "Student Web App VPC (10.0.0.0/16)"
3. Draw 2 vertical dividers (AZs)
4. Label: "AZ 1 (us-east-1a)" and "AZ 2 (us-east-1b)"

### Phase 3: Subnets (10 minutes)

1. In each AZ, draw 2 rectangles:
   - Top: Public Subnet (green)
   - Bottom: Private Subnet (orange)
2. Label with CIDR blocks
3. Add subnet icons from AWS set

### Phase 4: Core Components (15 minutes)

1. Add Internet Gateway (above VPC)
2. Add ALB (spanning public subnets)
3. Add Target Group (below ALB)
4. Add EC2 instances (in private subnets)
5. Add RDS instances (in private subnets)

### Phase 5: Security (10 minutes)

1. Add Security Group boxes
2. Add IAM Role icon
3. Add Secrets Manager icon
4. Draw connections (dashed lines)

### Phase 6: Connections & Flow (15 minutes)

1. Draw traffic flow arrows (blue, thick)
2. Draw database connections (green)
3. Draw replication arrow (purple)
4. Draw IAM/management connections (dashed)

### Phase 7: Labels & Details (10 minutes)

1. Add port numbers
2. Add instance types
3. Add scaling information
4. Add security group rules

### Phase 8: Polish (10 minutes)

1. Add legend
2. Add title and metadata
3. Color code components
4. Align and space evenly
5. Add callouts for key features

**Total Time**: ~75 minutes for a professional diagram

## Presentation Tips

### Slide 1: Overview

- High-level architecture
- Key components
- Business value

### Slide 2: Network Layer

- VPC structure
- Subnet design
- Routing

### Slide 3: Compute Layer

- Auto Scaling
- Load Balancing
- Instance details

### Slide 4: Database Layer

- Multi-AZ setup
- Backup strategy
- High availability

### Slide 5: Security

- Security groups
- IAM roles
- Secrets management

### Slide 6: Data Flow

- Request flow
- Response flow
- Failover scenarios

### Slide 7: Scalability & Performance

- Auto Scaling metrics
- Load distribution
- Performance characteristics

### Slide 8: Cost Optimization

- Resource sizing
- Reserved instances potential
- Cost breakdown

## Key Metrics to Include

- **Availability**: 99.95% (Multi-AZ)
- **Scalability**: 1-6 instances (auto-scaling)
- **Response Time**: < 200ms (typical)
- **Throughput**: Handles concurrent requests
- **Disaster Recovery**: Multi-AZ with automated backups
- **Security**: Network isolation, encrypted storage, IAM

## Color Scheme Recommendation

- **VPC**: Light Blue (#E3F2FD)
- **Public Subnets**: Light Green (#C8E6C9)
- **Private Subnets**: Light Orange (#FFE0B2)
- **Load Balancer**: Light Purple (#E1BEE7)
- **EC2 Instances**: Light Blue (#BBDEFB)
- **RDS Database**: Light Pink (#F8BBD0)
- **Security**: Light Yellow (#FFF9C4)
- **Internet**: White with border

## Export Formats

1. **PNG** (High Resolution): For presentations
2. **PDF**: For documentation
3. **SVG**: For web/vector graphics
4. **Draw.io format**: For future edits
