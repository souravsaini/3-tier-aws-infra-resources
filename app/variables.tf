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

variable "subnet_ids" {
  description = "Private Subnet Ids of VPC"
  type        = list(string)
}

variable "lc_name" {
  description = "Launch Configuration Name"
}

variable "root_volume_size" {
  default = 20
}

variable "ami_id" {
  description = "AMI ID for Launch Configuration"
  default     = "ami-06aa3f7caf3a30282"
}

variable "instance_type" {
  description = "Instance Type for Launch Configuration"
}

variable "asg_name" {
  description = "Autoscaling Group name"
}

variable "desired_capacity" {
  default = 1
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 2
}

variable "ssh_public_key" {
  description = "Public Key of key pair to be created to login to"
  type        = string
}

variable "db_instance_identifier" {
  description = "Database Instance Identifier"
  type        = string
}

variable "db_username" {
  description = "Username for the database."
}

variable "db_secret_name" {
  description = "AWS Secret Manager secret name"
}
