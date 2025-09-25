module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  node_groups = {
    ng-default = {
      desired_capacity = 3
      max_capacity     = 4
      min_capacity     = 2
      instance_types   = ["t3.medium"]
    }
  }

  manage_aws_auth = true
}
