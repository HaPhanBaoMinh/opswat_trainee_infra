terraform {
  backend "s3" {
    bucket = "opswat-trainee-project-backend"
    key    = "OPSWAT-project-infra"
    region = "ap-southeast-1"
    assume_role = {
      role_arn = "arn:aws:iam::026090549419:role/Opswat-Trainee-ProjectS3BackendRole"
    }
  }
}

// VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = var.availability_zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

// EKS 
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    eks_nodes = {
      instance_type = var.instance_type[0]
      desired_size  = var.desired_size
      max_size      = var.max_size
      min_size      = var.min_size
      ami_type      = var.ami_id
      capacity_type = "SPOT"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

