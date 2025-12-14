# Generate a private key
resource "tls_private_key" "webapp_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "webapp_key" {
  key_name   = var.key_name
  public_key = tls_private_key.webapp_key.public_key_openssh

  tags = {
    Name = "Web App Key Pair"
  }
}

# Save private key to file (optional - for local use)
resource "local_file" "private_key" {
  content         = tls_private_key.webapp_key.private_key_pem
  filename        = "${var.key_name}.pem"
  file_permission = "0400"
}
