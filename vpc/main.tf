provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name                 = var.vpc_name
  cidr                 = var.cidr_block
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true 
  enable_dns_support   = true
  enable_dns_hostnames = true
}
