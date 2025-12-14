# role.tf
# IAM Role and Instance Profile for EC2 instances

# IAM Role for EC2 instances
# Allows EC2 instances to access AWS services like Secrets Manager and SSM
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-role"
  }
}

# Attach AWS Systems Manager Core policy
# Enables SSM Session Manager for secure access to EC2 instances without SSH keys
resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach Secrets Manager Read/Write policy
# Allows EC2 instances to read database credentials from AWS Secrets Manager
resource "aws_iam_role_policy_attachment" "ec2_secrets_rw" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# IAM Instance Profile
# Attaches the IAM role to EC2 instances
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "${local.name_prefix}-ec2-profile"
  }
}
