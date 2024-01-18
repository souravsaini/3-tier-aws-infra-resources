# Fetch VPC CIDR block using data source
data "aws_vpc" "my_vpc" {
  id = var.vpc_id
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