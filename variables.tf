variable "ami_id" {
  description = "The AMI ID"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "OPSWAT-Trainee-Project-EKS"
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "availability_zones" {
  description = "The availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "cluster_version" {
  description = "The EKS cluster version"
  type        = string
  default     = "1.31"
}

variable "instance_type" {
  description = "The instance type"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "min_size" {
  description = "The minimum size of the worker group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum size of the worker group"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "The desired size of the worker group"
  type        = number
  default     = 1
}

variable "environment" {
  description = "The environment"
  type        = string
  default     = "dev"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "026090549419"

}
