provider "aws" {
  region = var.region
  profile = var.profile
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