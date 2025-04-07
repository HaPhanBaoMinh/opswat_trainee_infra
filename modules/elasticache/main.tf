
resource "aws_security_group" "redis_sg" {
  name        = "${var.name}-redis-sg"
  description = "Security group for Redis ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-redis-sg"
    Environment = var.environment
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.redis_subnet_ids

  tags = {
    Name        = "${var.name}-${var.environment}-redis-subnet-group"
    Environment = var.environment
  }
}

resource "aws_elasticache_replication_group" "redis_replication_group" {
  replication_group_id       = "${var.name}-${var.environment}-redis"
  description                = "Redis replication group for ${var.name} in ${var.environment} environment"
  node_type                  = var.redis_node_type
  engine_version             = "7.1"  
  engine                     = "redis"
  parameter_group_name       = "default.redis7"
  automatic_failover_enabled = false
  security_group_ids         = [aws_security_group.redis_sg.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name

  tags = {
    Name        = "${var.name}-${var.environment}-redis"
    Environment = var.environment
  }
}
