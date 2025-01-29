output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  value       = module.eks_cluster.eks_cluster_name
}

output "node_group_name" {
  description = "Name of the EKS Node Group"
  value       = module.node_group.node_group_name
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver IAM Role"
  value       = module.ebs_csi_driver.ebs_csi_driver_role_arn
}