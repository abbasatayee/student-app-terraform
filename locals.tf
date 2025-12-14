# locals.tf
# Common values and tags used across all resources

locals {
  # Project metadata
  project_name = "student-web-app"
  environment  = "production"

  # Common tags applied to all resources
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  # Resource naming prefix
  name_prefix = "student"
}
