# Project Structure

This document describes the organized folder structure of the Terraform project.

## Directory Organization

The project is organized into logical folders for better maintainability and clarity:

```
terraform/
├── network/                    # Networking resources
│   ├── vpc.tf                 # VPC, subnets, Internet Gateway, Route Tables
│   └── security.tf            # Security Groups
│
├── compute/                    # Compute resources
│   ├── ec2.tf                 # EC2 bootstrap instance
│   ├── asg.tf                 # Auto Scaling Group and Launch Template
│   └── keypair.tf             # SSH key pair generation
│
├── database/                   # Database resources
│   └── rds.tf                 # RDS MySQL database
│
├── load-balancer/              # Load balancing resources
│   └── alb.tf                 # Application Load Balancer configuration
│
├── iam/                        # Identity and Access Management
│   └── role.tf                # IAM roles and policies
│
├── secrets/                    # Secrets management
│   └── secrets.tf             # AWS Secrets Manager
│
├── shared/                     # Shared configuration files
│   ├── locals.tf              # Common values and tags
│   ├── variables.tf           # Input variables
│   ├── outputs.tf             # Output values
│   └── versions.tf            # Terraform and provider versions
│
├── main.tf                     # Root configuration entry point
├── .gitignore                  # Git ignore rules
└── README.md                   # Project documentation
```

## How It Works

Terraform automatically reads all `.tf` files recursively from subdirectories. This means:

- ✅ No additional configuration needed
- ✅ All resources are in the same Terraform state
- ✅ Cross-references between resources work seamlessly
- ✅ `terraform init`, `terraform plan`, and `terraform apply` work as normal

## Folder Descriptions

### `network/`

Contains all networking-related resources:

- VPC configuration
- Subnets (public and private)
- Internet Gateway
- Route Tables
- Security Groups

### `compute/`

Contains all compute-related resources:

- EC2 bootstrap instance
- Auto Scaling Group
- Launch Templates
- Key Pairs

### `database/`

Contains database resources:

- RDS MySQL instance
- DB Subnet Groups

### `load-balancer/`

Contains load balancing resources:

- Application Load Balancer
- Target Groups
- Listeners

### `iam/`

Contains IAM resources:

- IAM Roles
- IAM Instance Profiles
- Policy Attachments

### `secrets/`

Contains secrets management:

- AWS Secrets Manager secrets
- Secret versions

### `shared/`

Contains shared configuration files used across all modules:

- `locals.tf` - Common values and tags used across all resources
- `variables.tf` - Input variables for the entire infrastructure
- `outputs.tf` - Output values for important resources
- `versions.tf` - Terraform and provider version constraints

## Benefits of This Structure

1. **Better Organization**: Related resources are grouped together
2. **Easier Navigation**: Find resources quickly by category
3. **Improved Maintainability**: Changes to specific areas are isolated
4. **Scalability**: Easy to add new resources to appropriate folders
5. **Team Collaboration**: Different team members can work on different folders

## Usage

The folder structure doesn't change how you use Terraform:

```bash
# Initialize (reads all .tf files recursively)
terraform init

# Plan (validates all resources)
terraform plan

# Apply (creates all resources)
terraform apply

# Destroy (removes all resources)
terraform destroy
```

All commands work exactly the same as before!
