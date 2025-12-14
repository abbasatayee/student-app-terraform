# Architecture Diagram - Component Checklist

Use this checklist to ensure all components are included in your diagram.

## Component Inventory

### Network Layer (7 components)

- [ ] VPC (10.0.0.0/16)
- [ ] Availability Zone 1 (us-east-1a)
- [ ] Availability Zone 2 (us-east-1b)
- [ ] Public Subnet 1 (10.0.1.0/24)
- [ ] Public Subnet 2 (10.0.2.0/24)
- [ ] Private Subnet 1 (10.0.101.0/24)
- [ ] Private Subnet 2 (10.0.102.0/24)

### Connectivity (2 components)

- [ ] Internet Gateway
- [ ] Public Route Table (0.0.0.0/0 → IGW)

### Load Balancing (2 components)

- [ ] Application Load Balancer (ALB)
  - [ ] Port: 80 (HTTP)
  - [ ] Cross-zone load balancing: Enabled
  - [ ] HTTP/2: Enabled
- [ ] Target Group
  - [ ] Health check path: /
  - [ ] Health check interval: 30s
  - [ ] Healthy threshold: 2

### Compute Layer (5 components)

- [ ] Auto Scaling Group
  - [ ] Min: 1
  - [ ] Max: 6
  - [ ] Desired: 2
  - [ ] Scaling policy: CPU-based (80%)
- [ ] Launch Template
  - [ ] AMI: Custom (Ubuntu 22.04)
  - [ ] Instance type: t3.micro
- [ ] EC2 Instance 1 (AZ 1)
  - [ ] OS: Ubuntu 22.04 LTS
  - [ ] Application: Node.js
  - [ ] Port: 80
- [ ] EC2 Instance 2 (AZ 2)
  - [ ] OS: Ubuntu 22.04 LTS
  - [ ] Application: Node.js
  - [ ] Port: 80
- [ ] EC2 Key Pair (webapp-key)

### Database Layer (3 components)

- [ ] RDS MySQL Primary (AZ 1)
  - [ ] Engine: MySQL 8.0
  - [ ] Instance: db.t3.micro
  - [ ] Storage: 20 GB
  - [ ] Port: 3306
  - [ ] Multi-AZ: Enabled
- [ ] RDS MySQL Standby (AZ 2)
  - [ ] Replica of Primary
  - [ ] Automatic failover
- [ ] DB Subnet Group
  - [ ] Private subnets only

### Security Layer (4 components)

- [ ] Load Balancer Security Group
  - [ ] Inbound: HTTP (80) from 0.0.0.0/0
  - [ ] Inbound: HTTPS (443) from 0.0.0.0/0
  - [ ] Outbound: All
- [ ] Web Server Security Group
  - [ ] Inbound: HTTP (80) from LB SG
  - [ ] Outbound: All
- [ ] Database Security Group
  - [ ] Inbound: MySQL (3306) from Web SG
  - [ ] Outbound: All
- [ ] IAM Role (EC2)
  - [ ] SSM Managed Instance Core
  - [ ] Secrets Manager Read/Write

### Services (1 component)

- [ ] AWS Secrets Manager
  - [ ] Secret name: Mydbsecret
  - [ ] Contains: DB credentials

## Connection Checklist

### User Traffic Flow

- [ ] Internet → Internet Gateway
- [ ] Internet Gateway → Public Route Table
- [ ] Public Route Table → Public Subnets
- [ ] Internet Gateway → Application Load Balancer
- [ ] ALB → Target Group
- [ ] Target Group → EC2 Instance 1
- [ ] Target Group → EC2 Instance 2

### Database Connections

- [ ] EC2 Instance 1 → RDS Primary (MySQL 3306)
- [ ] EC2 Instance 2 → RDS Primary (MySQL 3306)
- [ ] RDS Primary ↔ RDS Standby (Replication)

### Security Associations

- [ ] LB Security Group → ALB
- [ ] Web Security Group → EC2 Instances
- [ ] Database Security Group → RDS Instances
- [ ] IAM Role → EC2 Instances
- [ ] Secrets Manager → EC2 Instances (via IAM)

## Labeling Checklist

### Each Component Should Have:

- [ ] Component name/type
- [ ] Key specifications (if applicable)
- [ ] Port numbers (if applicable)
- [ ] Instance types (if applicable)
- [ ] IP ranges (for subnets)

### Key Labels to Include:

- [ ] VPC CIDR: 10.0.0.0/16
- [ ] Subnet CIDRs: 10.0.1.0/24, 10.0.2.0/24, 10.0.101.0/24, 10.0.102.0/24
- [ ] Port 80 (HTTP) on ALB and EC2
- [ ] Port 3306 (MySQL) on RDS
- [ ] Instance types: t3.micro (EC2), db.t3.micro (RDS)
- [ ] Scaling: Min 1, Max 6, Desired 2

## Visual Elements Checklist

### Colors

- [ ] VPC: Light blue
- [ ] Public subnets: Light green
- [ ] Private subnets: Light orange
- [ ] Load balancer: Light purple
- [ ] EC2 instances: Light blue
- [ ] RDS: Light pink
- [ ] Security: Light yellow

### Arrows/Lines

- [ ] Thick blue arrows: User traffic
- [ ] Green arrows: Database traffic
- [ ] Purple arrows: Replication
- [ ] Dashed lines: IAM/Management
- [ ] Red lines: Security group associations

### Text Boxes

- [ ] Title: "Student Web Application - AWS Infrastructure"
- [ ] Subtitle: "High Availability, Scalable, Secure"
- [ ] Legend explaining colors and line types
- [ ] Metadata box with key metrics

## Presentation Slides Breakdown

### Slide 1: High-Level Overview

- [ ] Entire architecture
- [ ] Key components highlighted
- [ ] Data flow shown

### Slide 2: Network Architecture

- [ ] VPC structure
- [ ] Subnet design
- [ ] Routing tables
- [ ] Internet Gateway

### Slide 3: Compute & Scaling

- [ ] Auto Scaling Group
- [ ] Load Balancer
- [ ] EC2 instances
- [ ] Scaling metrics

### Slide 4: Database Architecture

- [ ] Multi-AZ setup
- [ ] Primary and Standby
- [ ] Replication flow
- [ ] Backup strategy

### Slide 5: Security Architecture

- [ ] Security groups
- [ ] IAM roles
- [ ] Secrets Manager
- [ ] Network isolation

### Slide 6: Data Flow

- [ ] Request flow (step by step)
- [ ] Response flow
- [ ] Database queries
- [ ] Failover scenarios

## Key Metrics to Display

- [ ] Availability: 99.95% (Multi-AZ)
- [ ] Scalability: 1-6 instances (auto-scaling)
- [ ] Response Time: < 200ms
- [ ] Throughput: Concurrent request handling
- [ ] Disaster Recovery: Multi-AZ with 7-day backups
- [ ] Security: Network isolation, encryption, IAM

## Technical Specifications Table

Include a table with:

| Component       | Specification | Value                        |
| --------------- | ------------- | ---------------------------- |
| VPC             | CIDR          | 10.0.0.0/16                  |
| Public Subnets  | CIDR          | 10.0.1.0/24, 10.0.2.0/24     |
| Private Subnets | CIDR          | 10.0.101.0/24, 10.0.102.0/24 |
| EC2 Instance    | Type          | t3.micro                     |
| EC2 Instance    | OS            | Ubuntu 22.04 LTS             |
| RDS             | Engine        | MySQL 8.0                    |
| RDS             | Instance      | db.t3.micro                  |
| RDS             | Storage       | 20 GB                        |
| RDS             | Multi-AZ      | Enabled                      |
| ASG             | Min Size      | 1                            |
| ASG             | Max Size      | 6                            |
| ASG             | Desired       | 2                            |
| ALB             | Protocol      | HTTP (Port 80)               |
| Database        | Port          | 3306                         |
