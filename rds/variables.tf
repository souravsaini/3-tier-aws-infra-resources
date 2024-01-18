variable "region" {
  description = "AWS region where the resources will be created."
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS Profile"
  default     = "rd"
}

variable "vpc_id" {
  description = "VPC ID in which RDS instance to be launched"
}

variable "rds_instance_identifier" {
  description = "Identifier for the RDS instance."
}

variable "family" {
  description = "For DB Parameter Group"
  default     =  "mysql8.0"
}

variable "db_engine" {
  description = "Database engine for the RDS instance."
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version for the RDS instance."
  default     = "8.0.35"
}

variable "db_instance_class" {
  description = "RDS instance class."
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance (in GB)."
  default     = 20
}

variable "db_name" {
  description = "Name of the database."
}

variable "db_username" {
  description = "Username for the database."
}

variable "db_secret_name" {
  description = "AWS Secret Manager secret name"
}

variable "multi_az" {
  description = "Enable multi-AZ deployment for the RDS instance."
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs in which the RDS instance will be deployed."
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible."
  default     = false
}


variable "backup_window" {
  description = "Backup Window Time"
  default     = "22:00-23:00"
}

variable "maintenance_window" {
  description = "Maintenance Window Time"
  default     = "Mon:00:00-Mon:03:00"
}

variable "db_subnet_group_name" {
  description = "DB Subnet Group Name"
}
