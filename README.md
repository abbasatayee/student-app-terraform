# Student VPC Infrastructure with RDS

This Terraform project provisions a complete AWS infrastructure setup for a student application, including a VPC with public and private subnets, and an RDS MySQL database.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Variables](#variables)
- [Infrastructure Components](#infrastructure-components)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This project creates a secure, production-ready AWS infrastructure with:

- **VPC**: Custom Virtual Private Cloud with CIDR block 10.0.0.0/16
- **Public Subnets**: Two public subnets across different availability zones for web servers
- **Private Subnets**: Two private subnets across different availability zones for database
- **RDS MySQL Database**: Multi-AZ MySQL 8.0 database instance in private subnets
- **Security Groups**: Network security rules for web and database access
- **Internet Gateway**: Enables internet access for public subnets
- **Route Tables**: Routes traffic appropriately between public and private subnets

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      VPC (10.0.0.0/16)                  │
│                                                          │
                                │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │ Private Subnet 1 │      │ Private Subnet 2 │        │
│  │ (10.0.101.0/24)  │      │ (10.0.102.0/24)  │        │
│  │                  │      │                  │        │
│  │  [RDS MySQL]     │      │  [RDS Standby]   │        │
│  └──────────────────┘      └──────────────────┘
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  Public Subnet 1 │      │  Public Subnet 2 │        │
│  │   (10.0.1.0/24)  │      │   (10.0.2.0/24)  │        │
│  │                  │      │                  │        │
│  │  [Web Servers]   │      │  [Web Servers]   │        │
│  └────────┬─────────┘      └────────┬─────────┘        │
│           │                         │                   │
│           └──────────┬──────────────┘                   │
│                      │                                  │
│              [Internet Gateway]                         │
│                      │      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## 📦 Prerequisites

Before you begin, ensure you have the following:

### 1. AWS User Setup (Required First Step)

**You must manually create an AWS IAM user with the necessary permissions before using this Terraform project.**

#### Steps to Create AWS User:

1. **Log in to AWS Console** and navigate to **IAM (Identity and Access Management)**

2. **Create a new IAM User:**

   - Go to **Users** → **Create user**
   - Enter a username (e.g., `terraform-user`)
   - Select **Provide user access to the AWS Management Console** (optional) or **Access key - Programmatic access** (required for Terraform)
   - Click **Next**

3. **Attach Permissions:**

   - Select **Attach policies directly**
   - Attach the following policies:
     - **AmazonEC2FullAccess** - Provides full access to EC2 services
     - **AdministratorAccess** - Provides full access to AWS services and resources
   - Click **Next** → **Create user**

4. **Save Access Credentials:**
   - **Important**: Download or copy the **Access Key ID** and **Secret Access Key**
   - These credentials will be used to configure AWS CLI and Terraform
   - ⚠️ **Store these securely** - you won't be able to view the secret key again

#### Alternative: Custom Policy (More Secure)

For better security, you can create a custom policy with only the required permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*", "rds:*", "vpc:*", "iam:PassRole"],
      "Resource": "*"
    }
  ]
}
```

### 2. Terraform (>= 1.5.0)

```bash
terraform version
```

### 3. AWS CLI Configuration

Configure AWS CLI with the credentials from the user you created:

```bash
aws configure
```

When prompted, enter:

- **AWS Access Key ID**: Your access key from step 1
- **AWS Secret Access Key**: Your secret key from step 1
- **Default region**: e.g., `us-east-1`
- **Default output format**: `json`

### 4. AWS Credentials Verification

Verify your credentials are working:

```bash
aws sts get-caller-identity
```

This should return your user ARN and account information.

### 5. Required AWS Permissions

The IAM user must have permissions to create:

- VPCs and networking components
- RDS instances
- Security groups
- Subnets and route tables
- EC2 instances (if you plan to add them later)

## 🚀 Installation

1. **Initialize Terraform:**

```bash
terraform init
```

This will download the required AWS provider plugins.

## ⚙️ Configuration

### Default Configuration

The project comes with sensible defaults defined in `variables.tf`:

- **Region**: `us-east-1`
- **VPC CIDR**: `10.0.0.0/16`
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Private Subnets**: `10.0.101.0/24`, `10.0.102.0/24`
- **Database Name**: `STUDENTS`
- **Database Username**: `nodeapp`
- **Database Password**: `student12` ⚠️ **Change this in production!**

### Customizing Configuration

You can customize the infrastructure in several ways:

#### Option 1: Create a `terraform.tfvars` file

Create a `terraform.tfvars` file in the project root:

```hcl
aws_region = "us-west-2"
vpc_cidr   = "10.0.0.0/16"

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

db_name     = "STUDENTS"
db_username = "nodeapp"
db_password = "your-secure-password-here"

instance_type = "t3.micro"
key_name      = "your-key-pair-name"
```

#### Option 2: Use command-line variables

```bash
terraform apply -var="db_password=my-secure-password" -var="aws_region=us-west-2"
```

#### Option 3: Use environment variables

```bash
export TF_VAR_db_password="my-secure-password"
export TF_VAR_aws_region="us-west-2"
terraform apply
```

## 📖 Usage

### Step 1: Review the Execution Plan

Before creating resources, always review what Terraform will create:

```bash
terraform plan
```

This will show you:

- Resources that will be created
- Resources that will be modified
- Resources that will be destroyed

### Step 2: Apply the Configuration

If the plan looks correct, apply it to create the infrastructure:

```bash
terraform apply
```

Terraform will prompt you to confirm. Type `yes` to proceed.

**Note**: This will create AWS resources that may incur costs. The RDS instance uses Multi-AZ which doubles the database cost.

### Step 3: Verify the Infrastructure

After successful deployment, you can verify the resources:

```bash
# List VPCs
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Student VPC"

# List subnets
aws ec2 describe-subnets --filters "Name=tag:Name,Values=Public Subnet*"

# Check RDS instance
aws rds describe-db-instances --db-instance-identifier student-database
```

### Step 4: Access the Database

The RDS MySQL database is deployed in private subnets and is not publicly accessible. To connect:

1. **From an EC2 instance in the public subnet:**

   ```bash
   mysql -h student-database.xxxxx.us-east-1.rds.amazonaws.com \
         -u nodeapp \
         -p
   ```

2. **Connection details:**
   - **Host**: Use the RDS endpoint (found in AWS Console or via `aws rds describe-db-instances`)
   - **Port**: 3306
   - **Database**: STUDENTS
   - **Username**: nodeapp (or your custom username)
   - **Password**: The password you configured

## 📝 Variables

| Variable          | Description                             | Default                              | Required |
| ----------------- | --------------------------------------- | ------------------------------------ | -------- |
| `aws_region`      | AWS region to deploy resources          | `us-east-1`                          | No       |
| `vpc_cidr`        | CIDR block for the VPC                  | `10.0.0.0/16`                        | No       |
| `public_subnets`  | List of CIDR blocks for public subnets  | `["10.0.1.0/24", "10.0.2.0/24"]`     | No       |
| `private_subnets` | List of CIDR blocks for private subnets | `["10.0.101.0/24", "10.0.102.0/24"]` | No       |
| `db_name`         | Name of the MySQL database              | `STUDENTS`                           | No       |
| `db_username`     | Master username for RDS                 | `nodeapp`                            | No       |
| `db_password`     | Master password for RDS                 | `student12`                          | No       |
| `instance_type`   | EC2 instance type                       | `t3.micro`                           | No       |
| `key_name`        | EC2 Key Pair name                       | `webapp-key`                         | No       |

## 🏛️ Infrastructure Components

### VPC (`vpc.tf`)

- **VPC**: Main VPC with configurable CIDR block
- **Public Subnets**: Two subnets across different AZs for web servers
- **Private Subnets**: Two subnets across different AZs for database
- **Internet Gateway**: Enables internet access
- **Route Tables**: Routes traffic for public subnets

### RDS (`rds.tf`)

- **MySQL 8.0 Database**: Multi-AZ deployment for high availability
- **Instance Class**: `db.t3.micro` (20 GB storage)
- **Subnet Group**: Uses private subnets for security
- **Not Publicly Accessible**: Database is only accessible from within VPC

### Security Groups (`security.tf`)

- **Web Security Group**: Allows HTTP (port 80) from anywhere
- **Database Security Group**: Allows MySQL (port 3306) only from web security group

## 🧹 Cleanup

To destroy all created resources and avoid ongoing charges:

```bash
terraform destroy
```

Terraform will show you what will be destroyed and ask for confirmation. Type `yes` to proceed.

**Warning**: This will permanently delete:

- The RDS database and all data
- All networking components
- Security groups

Make sure you have backups if needed!

## 🔧 Troubleshooting

### Error: "Reference to undeclared resource"

If you see errors about undeclared resources, ensure all `.tf` files are in the same directory and run `terraform init` again.

### Error: "InvalidParameterValue: The parameter identifier is already in use"

The RDS identifier `student-database` already exists. Either:

- Change the identifier in `rds.tf`
- Delete the existing RDS instance
- Use a different AWS region

### Error: "InvalidKeyPair.NotFound"

The EC2 key pair specified in `key_name` doesn't exist in your AWS account. Either:

- Create the key pair in AWS Console
- Update `key_name` variable to match an existing key pair

### Database Connection Issues

- Ensure you're connecting from within the VPC (e.g., from an EC2 instance)
- Verify the security group allows traffic from your source
- Check that the RDS instance is in "available" status

### Cost Optimization

- The RDS instance uses Multi-AZ which doubles the cost. For development, you can set `multi_az = false` in `rds.tf`
- Consider using `db.t3.micro` for development and upgrading for production
- Always run `terraform destroy` when not using the infrastructure

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)

## 📄 License

This project is provided as-is for educational purposes.

## 🤝 Contributing

Feel free to submit issues or pull requests for improvements.

---

**Note**: Remember to change default passwords and review security settings before deploying to production!
