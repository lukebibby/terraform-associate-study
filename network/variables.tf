/* Variable definitions for base network infrastructere */

variable "vpc_cidr_block" {
  description = "IP Prefix for use within VPC"
  type        = string
}

variable "vpc_private_subnet_cidr_block" {
  description = "IP Prefix for private subnet in VPC"
  type        = string
}

/*
variable "vpc_public_subnet_az1_cidr_block" {
  description = "IP Prefix for public subnet in VPC AZ1"
  type        = string
}

variable "vpc_public_subnet_az2_cidr_block" {
  description = "IP Prefix for public subnet in VPC AZ1"
  type        = string
}
*/

variable "vpc_public_subnets" {
  description = "IP prefixes for public subnets"
  type        = map(any)
}