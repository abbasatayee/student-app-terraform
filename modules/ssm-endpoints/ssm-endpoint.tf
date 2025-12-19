resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.ssm_security_group_id]

  private_dns_enabled = true

  tags = merge(
    {
      Name = "ssm-vpc-endpoint"
    },
    var.common_tags
  )
}


resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.ssm_security_group_id]

  private_dns_enabled = true

  tags = merge(
    {
      Name = "ec2messages-vpc-endpoint"
    },
    var.common_tags
  )
}


resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.ssm_security_group_id]

  private_dns_enabled = true

  tags = merge(
    {
      Name = "ssmmessages-vpc-endpoint"
    },
    var.common_tags
  )
}
