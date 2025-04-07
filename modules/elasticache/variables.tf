variable "environment" {
  type        = string
  description = "The environment for the Redis instance (e.g., dev, prod)"
}

variable "name" {
  type        = string
  description = "The name of the Redis instance"
}

variable "redis_node_type" {
  type        = string
  description = "The instance type for the Redis nodes"
  default     = "cache.t3.micro"
}

variable "redis_node_count" {
  type        = number
  description = "The number of Redis nodes in the replication group"
  default     = 1
}

variable "redis_subnet_group_name" {
  type        = string
  description = "The name of the Redis subnet group"
}

variable "redis_subnet_ids" {
  type        = list(string)
  description = "The list of subnet IDs for the Redis subnet group"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the Redis instance will be created"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks that are allowed to access the Redis instance"
  default     = ["0.0.0.0/0"]
}

variable "redis_port" {
  type        = number
  description = "The port on which the Redis instance is listening"
  default     = 6379
}
