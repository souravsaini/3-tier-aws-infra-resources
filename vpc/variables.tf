variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}