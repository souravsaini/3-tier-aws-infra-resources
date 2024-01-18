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

variable "private_subnet_ids" {
  description = "Private Subnet Ids of VPC"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Private Subnet Ids of VPC"
  type        = list(string)
}

variable "lc_name" {
  description = "Launch Configuration Name"
}

variable "root_volume_size" {
  default = 10
}

variable "ami_id" {
  description = "AMI ID for Launch Configuration"
  default     = "ami-0c7217cdde317cfec"
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

variable "ssh_key_name" {
  description = "Key pair name created in AWS"
  type        = string
}

variable "internal_alb_endpoint" {
  description = "Internal ALB Endpoint"
  type        = string
}