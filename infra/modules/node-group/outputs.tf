output "node_group_name" {
  description = "Name of the EKS Node Group"
  value       = aws_eks_node_group.node_group.node_group_name
}

output "node_group_role_arn" {
  description = "ARN of the EKS Node Group IAM Role"
  value       = aws_iam_role.eks_node_group_role.arn
}
