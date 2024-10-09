# list of all AZs in given region
data "aws_availability_zones" "available" {}

###############################################################################
### VPC
### https://github.com/terraform-aws-modules/terraform-aws-vpc
###############################################################################
#trivy:ignore:avd-aws-0178:MEDIUM: VPC Flow Logs is not enabled for VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.env_name}-vpc"
  cidr = var.vpc_cidr

  azs              = data.aws_availability_zones.available.names
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  #only for prod, for non-prod envs we use NAT-instance for reducing costs
  enable_nat_gateway = var.env_name == "prod" ? true : false
  #single_nat_gateway = true
}


###############################################################################
### NAT-instance (for non-prod envs only)
### https://github.com/int128/terraform-aws-nat-instance
###############################################################################
#trivy:ignore:avd-aws-0057:HIGH: IAM policy document uses sensitive action 'ec2:AttachNetworkInterface' on wildcarded resource '*'
#trivy:ignore:avd-aws-0104:CRITICAL: Security group rule allows egress to multiple public internet addresses.
#trivy:ignore:avd-aws-0124:LOW: Security group rule does not have a description.
module "nat" {
  count = var.env_name == "prod" ? 0 : 1

  source  = "int128/nat-instance/aws"
  version = "2.1.0"

  name                        = "main"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

#trivy:ignore:avd-aws-0107:CRITICAL: Security group rule allows ingress from public internet.
resource "aws_security_group_rule" "nat_ssh" {
  # SSH to bastion, only for non-prod
  count = var.env_name == "prod" ? 0 : 1

  description       = "SSH to bastion"
  security_group_id = module.nat[0].sg_id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

resource "aws_eip" "nat" {
  count = var.env_name == "prod" ? 0 : 1

  network_interface = module.nat[0].eni_id
  tags = {
    "Name" = "nat-instance-main"
  }
}
