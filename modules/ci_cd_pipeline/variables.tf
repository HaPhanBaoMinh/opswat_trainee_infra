variable "services" {
  type = map(object({
    github_owner = string
    github_repo  = string
    branch       = string
    path         = string
  }))
  description = "Map of services with their repo configurations"
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the CodeStar connection"
  default     = "test"
}

variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "name" {
  description = "The name of the project"
  type        = string
  default     = "opwat-trainee-project"
}

variable "environment" {
  description = "The environment for the project (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}
