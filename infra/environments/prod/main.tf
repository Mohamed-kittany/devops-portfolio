module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  cidr_block   = var.cidr_block
  cluster_name = var.cluster_name
  tags         = var.tags
}

module "eks_cluster" {
  source       = "../../modules/eks-cluster"
  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name
  subnet_ids   = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  eks_version  = var.eks_version
  tags         = var.tags

  depends_on = [module.vpc]
}

module "node_group" {
  source        = "../../modules/node-group"
  project_name  = var.project_name
  environment   = var.environment
  cluster_name  = var.cluster_name
  subnet_ids    = module.vpc.private_subnet_ids
  desired_size  = var.desired_size
  max_size      = var.max_size
  min_size      = var.min_size
  instance_types = var.instance_types
  tags          = var.tags

  depends_on = [module.eks_cluster]
}


module "ebs_csi_driver" {
  source        = "../../modules/ebs-csi-driver"
  project_name  = var.project_name
  environment   = var.environment
  cluster_name  = module.eks_cluster.eks_cluster_name
  oidc_issuer   = module.eks_cluster.oidc_issuer
  tags          = var.tags

  depends_on = [module.eks_cluster, module.node_group]
}

module "k8s_secrets" {
  source = "../../modules/k8s-secrets"

  # Pass the entire list of configurations
  k8s_secrets_config = var.k8s_secrets_config

  depends_on = [ module.eks_cluster, module.node_group ]
}