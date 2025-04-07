variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-southeast-1"
}

variable "name" {
  description = "Name for the VPC and subnets"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
}
