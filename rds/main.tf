provider "aws" {
  region = var.region
  profile = var.profile
}

# Fetch VPC CIDR block using data source
data "aws_vpc" "my_vpc" {
  id = var.vpc_id
}

# Create a default security group for rds instance
resource "aws_security_group" "rds_security_group" {
  vpc_id = data.aws_vpc.my_vpc.id

  // 3306 port open for MySQL traffic
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.my_vpc.cidr_block]
  }
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "secret_username" {
  arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.db_username}"
}


#Fetch DB Password from AWS Secret Manager
data "aws_secretsmanager_secret_version" "rds_username" {
  secret_id = data.aws_secretsmanager_secret.secret_username.id
}


data "aws_secretsmanager_secret" "secret_password" {
  arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.db_secret_name}"
}

#Fetch DB Password from AWS Secret Manager
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.secret_password.id
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.1"

  # RDS instance settings
  identifier             = var.rds_instance_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  major_engine_version   = var.db_engine_version
  family                 = var.family
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  manage_master_user_password = false
  username               = data.aws_secretsmanager_secret_version.rds_username.secret_string
  password               = data.aws_secretsmanager_secret_version.rds_password.secret_string
  apply_immediately      = true
  create_db_subnet_group = true
  db_subnet_group_name   = var.db_subnet_group_name
  create_db_parameter_group = false
  create_db_option_group    = false 

  # Multi-AZ and replication settings
  multi_az                      = var.multi_az

  # Security group settings
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  # Subnet settings
  subnet_ids = var.subnet_ids

  # Other optional settings (customize as needed)
  publicly_accessible                 = var.publicly_accessible
  backup_retention_period             = 7
  backup_window                       = var.backup_window
  maintenance_window                  = var.maintenance_window
  iam_database_authentication_enabled = false
  auto_minor_version_upgrade          = true
  skip_final_snapshot                 = true //should be false for production

  # Tags
  tags = {
    Name        = var.rds_instance_identifier
    Environment = "Production"
  }
}