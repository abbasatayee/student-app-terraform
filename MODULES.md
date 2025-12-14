# Terraform Modules Documentation

This project uses a modular architecture with reusable Terraform modules. Each module encapsulates a specific infrastructure component and can be reused across different environments.

## Module Structure

```
terraform/
├── modules/                    # Reusable modules
│   ├── network/               # Networking module
│   ├── compute/               # Compute module
│   ├── database/              # Database module
│   ├── load-balancer/         # Load balancer module
│   ├── iam/                   # IAM module
│   └── secrets/               # Secrets module
├── main.tf                    # Root module (calls all modules)
├── variables.tf               # Root variables
├── outputs.tf                 # Root outputs
├── locals.tf                  # Root locals
└── versions.tf                # Provider versions
```

## Modules Overview

### 1. Network Module (`modules/network/`)

**Purpose**: Creates VPC, subnets, Internet Gateway, Route Tables, and Security Groups.

**Inputs**:

- `vpc_cidr` - VPC CIDR block
- `public_subnets` - List of public subnet CIDRs
- `private_subnets` - List of private subnet CIDRs
- `name_prefix` - Resource naming prefix
- `common_tags` - Common tags for resources

**Outputs**:

- `vpc_id` - VPC ID
- `public_subnet_ids` - Public subnet IDs
- `private_subnet_ids` - Private subnet IDs
- `web_sg_id` - Web security group ID
- `db_sg_id` - Database security group ID
- `lb_sg_id` - Load balancer security group ID

### 2. IAM Module (`modules/iam/`)

**Purpose**: Creates IAM roles and instance profiles for EC2 instances.

**Inputs**:

- `name_prefix` - Resource naming prefix
- `common_tags` - Common tags for resources

**Outputs**:

- `ec2_role_name` - EC2 IAM role name
- `ec2_instance_profile_name` - EC2 instance profile name

### 3. Database Module (`modules/database/`)

**Purpose**: Creates RDS MySQL database instance.

**Inputs**:

- `name_prefix` - Resource naming prefix
- `db_name` - Database name
- `db_username` - Database username
- `db_password` - Database password
- `rds_instance_class` - RDS instance class
- `rds_allocated_storage` - Storage size in GB
- `rds_multi_az` - Enable Multi-AZ
- `private_subnet_ids` - Private subnet IDs
- `db_security_group_id` - Database security group ID
- `common_tags` - Common tags

**Outputs**:

- `rds_endpoint` - RDS endpoint
- `rds_port` - RDS port
- `rds_database_name` - Database name

### 4. Load Balancer Module (`modules/load-balancer/`)

**Purpose**: Creates Application Load Balancer, Target Group, and Listener.

**Inputs**:

- `name_prefix` - Resource naming prefix
- `vpc_id` - VPC ID
- `public_subnet_ids` - Public subnet IDs
- `lb_security_group_id` - Load balancer security group ID
- `common_tags` - Common tags

**Outputs**:

- `alb_dns_name` - ALB DNS name
- `alb_arn` - ALB ARN
- `target_group_arn` - Target group ARN

### 5. Compute Module (`modules/compute/`)

**Purpose**: Creates EC2 bootstrap instance, Auto Scaling Group, Launch Template, and Key Pair.

**Inputs**:

- `name_prefix` - Resource naming prefix
- `instance_type` - EC2 instance type
- `key_name` - Key pair name
- `public_subnets` - Public subnets map
- `private_subnet_ids` - Private subnet IDs
- `web_security_group_id` - Web security group ID
- `iam_instance_profile_name` - IAM instance profile name
- `asg_min_size` - ASG minimum size
- `asg_max_size` - ASG maximum size
- `asg_desired_capacity` - ASG desired capacity
- `asg_target_cpu_utilization` - Target CPU utilization
- `target_group_arn` - Target group ARN
- `rds_endpoint` - RDS endpoint
- `db_username` - Database username
- `db_password` - Database password
- `db_name` - Database name
- `common_tags` - Common tags

**Outputs**:

- `bootstrap_instance_id` - Bootstrap instance ID
- `asg_name` - Auto Scaling Group name
- `web_ami_id` - Custom AMI ID
- `key_pair_name` - Key pair name

### 6. Secrets Module (`modules/secrets/`)

**Purpose**: Creates AWS Secrets Manager secret for database credentials.

**Inputs**:

- `name_prefix` - Resource naming prefix
- `db_username` - Database username
- `db_password` - Database password
- `db_name` - Database name
- `rds_endpoint` - RDS endpoint
- `common_tags` - Common tags

**Outputs**:

- `db_secret_arn` - Secret ARN

## Module Dependencies

```
network (no dependencies)
  ↓
iam (no dependencies)
  ↓
database (depends on: network)
  ↓
load_balancer (depends on: network)
  ↓
compute (depends on: network, iam, database, load_balancer)
  ↓
secrets (depends on: database)
```

## Benefits of Modular Architecture

1. **Reusability**: Modules can be reused across different environments (dev, staging, prod)
2. **Maintainability**: Changes to one module don't affect others
3. **Testability**: Each module can be tested independently
4. **Clarity**: Clear separation of concerns
5. **Scalability**: Easy to add new modules or modify existing ones
6. **Team Collaboration**: Different teams can work on different modules

## Usage

### Using the Root Module

The root `main.tf` calls all modules and passes variables between them:

```hcl
module "network" {
  source = "./modules/network"
  # ... variables
}

module "database" {
  source = "./modules/database"
  private_subnet_ids = module.network.private_subnet_ids
  # ... other variables
}
```

### Using Modules Independently

You can also use modules independently in other projects:

```hcl
module "my_network" {
  source = "path/to/modules/network"

  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  name_prefix     = "my-app"
  common_tags     = {
    Environment = "production"
  }
}
```

## Module Best Practices

1. **Input Variables**: All module inputs should be defined in `variables.tf`
2. **Outputs**: All module outputs should be defined in `outputs.tf`
3. **Documentation**: Each module should have clear documentation
4. **Versioning**: Consider versioning modules for production use
5. **Testing**: Test modules independently before integration
6. **Naming**: Use consistent naming conventions across modules

## Adding a New Module

1. Create a new directory in `modules/`
2. Add `variables.tf` with all inputs
3. Add `outputs.tf` with all outputs
4. Add resource files (e.g., `main.tf` or specific resource files)
5. Update root `main.tf` to call the new module
6. Update root `outputs.tf` if needed

## Migration from Flat Structure

The project was migrated from a flat file structure to a modular architecture. The old folders (`network/`, `compute/`, etc. in root) are kept for reference but are no longer used. The active modules are in `modules/`.
