
# EKS Cluster Module
module "eks" {
  source                    = "./modules/eks"
  name                      = "${var.name}-eks-cluster"
  node_group_name           = "${var.name}-node-group"
  instance_types            = ["t3.medium"]
  node_group_size           = 1
  node_group_max_size       = 2
  node_group_min_size       = 1
  environment               = var.environment
  capacity_type             = "SPOT"
  additional_instance_types = ["t3.medium"]
  tags                      = var.tags
  availability_zones        = var.availability_zones
  enable_nat_gateway        = var.enable_nat_gateway
}

module "rds" {
  source              = "./modules/rds"
  db_name             = "${var.name}-rds"
  environment         = var.environment
  subnet_ids          = module.eks.private_subnet_ids
  vpc_id              = module.eks.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
  db_port             = var.db_port
  db_instance_class   = var.db_instance_class
}


module "elasticache" {
  source              = "./modules/elasticache"
  name                = "${var.name}-redis"
  environment         = var.environment
  vpc_id              = module.eks.vpc_id
  redis_subnet_ids    = module.eks.private_subnet_ids
  allowed_cidr_blocks = var.allowed_cidr_blocks
  redis_subnet_group_name = "${var.name}-${var.environment}-redis-subnet-group"
}
