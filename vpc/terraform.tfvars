region          = "us-east-1"
profile         = "rd"
vpc_name        = "php-webapp-vpc"
cidr_block      = "100.0.0.0/20"
azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnets = ["100.0.1.0/24", "100.0.2.0/24", "100.0.3.0/24"]
public_subnets  = ["100.0.4.0/26", "100.0.5.0/26", "100.0.6.0/26"]