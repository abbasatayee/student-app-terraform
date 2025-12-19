# main.tf
# Root module that orchestrates all infrastructure modules

# Network Module
# Creates VPC, subnets, Internet Gateway, Route Tables, and Security Groups
module "network" {
  source = "./modules/network"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  name_prefix     = local.name_prefix
  common_tags     = local.common_tags
}

# IAM Module
# Creates IAM roles and instance profiles for EC2 instances
module "iam" {
  source      = "./modules/iam"
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# Database Module
# Creates RDS MySQL database instance
module "database" {
  source = "./modules/database"

  name_prefix           = local.name_prefix
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  rds_instance_class    = var.rds_instance_class
  rds_allocated_storage = var.rds_allocated_storage
  rds_multi_az          = var.rds_multi_az
  private_subnet_ids    = module.network.private_subnet_ids
  db_security_group_id  = module.network.db_sg_id
  common_tags           = local.common_tags
}

# Load Balancer Module
# Creates Application Load Balancer, Target Group, and Listener
module "load_balancer" {
  source = "./modules/load-balancer"

  name_prefix          = local.name_prefix
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  lb_security_group_id = module.network.lb_sg_id
  common_tags          = local.common_tags
}

# Compute Module
# Creates EC2 bootstrap instance, Auto Scaling Group, Launch Template, and Key Pair
module "compute" {
  source = "./modules/compute"

  name_prefix                = local.name_prefix
  instance_type              = var.instance_type
  key_name                   = var.key_name
  public_subnets             = module.network.public_subnets
  private_subnet_ids         = module.network.private_subnet_ids
  web_security_group_id      = module.network.web_sg_id
  iam_instance_profile_name  = var.iam_instance_profile_name
  asg_min_size               = var.asg_min_size
  asg_max_size               = var.asg_max_size
  asg_desired_capacity       = var.asg_desired_capacity
  asg_target_cpu_utilization = var.asg_target_cpu_utilization
  target_group_arn           = module.load_balancer.target_group_arn
  rds_endpoint               = module.database.rds_endpoint
  db_username                = var.db_username
  db_password                = var.db_password
  db_name                    = var.db_name
  common_tags                = local.common_tags

  depends_on = [
    module.database,
    module.load_balancer
  ]
}

# Secrets Module
# Creates AWS Secrets Manager secret for database credentials
# Secret name is fixed as "Mydbsecret" as per project requirements
module "secrets" {
  source = "./modules/secrets"

  name_prefix  = local.name_prefix
  db_username  = var.db_username
  db_password  = var.db_password
  db_name      = var.db_name
  rds_endpoint = module.database.rds_endpoint
  common_tags  = local.common_tags

  depends_on = [module.database]
}


# SSM Endpoints Module
#
# This module provisions AWS Systems Manager (SSM) VPC endpoints within the specified VPC.
# The SSM endpoints enable EC2 instances located in private subnets to communicate with
# SSM services without requiring direct Internet access or a NAT gateway. This greatly
# enhances security posture by allowing management and automation via SSM in air-gapped environments.
#
# All required configuration is passed from the root module:
#   - name_prefix: A common prefix for resource names for easier identification.
#   - vpc_id: The ID of the VPC where endpoints will be created.
#   - ssm_security_group_id: The security group to attach to endpoint network interfaces.
#   - common_tags: Tags to apply to the resources for identification and cost allocation.
#   - aws_region: The AWS region for the resources.
#   - private_subnet_ids: The list of private subnet IDs for endpoint placement.
#
# This module is critical for enabling SSM (Session Manager, Run Command, etc.) access in private network environments.
module "ssm" {
  source = "./modules/ssm-endpoints"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  ssm_security_group_id = module.network.ssm_vpc_endpoint_sg_id
  common_tags           = local.common_tags
  aws_region            = var.aws_region
  private_subnet_ids    = module.network.private_subnet_ids

  depends_on = [module.network]
}
