# keypair.tf
# EC2 Key Pair for SSH access to instances

# Generate a private key using TLS provider
resource "tls_private_key" "webapp_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
# This key pair can be used to SSH into EC2 instances
resource "aws_key_pair" "webapp_key" {
  key_name   = var.key_name
  public_key = tls_private_key.webapp_key.public_key_openssh

  tags = merge(
    {
      Name = "${var.name_prefix}-keypair"
    },
    var.common_tags
  )
}

# Save private key to local file
# ⚠️ WARNING: This file contains sensitive information. Keep it secure!
# The private key is saved with restrictive permissions (0400 = read-only for owner)
resource "local_file" "private_key" {
  content         = tls_private_key.webapp_key.private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0400"
}
