output "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  value       = aws_eks_cluster.todoapp_eks_cluster.name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS Cluster"
  value       = aws_eks_cluster.todoapp_eks_cluster.arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS Cluster"
  value       = aws_eks_cluster.todoapp_eks_cluster.endpoint
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS Cluster Role"
  value       = aws_iam_role.todoapp_eks_cluster_role.arn
}

output "oidc_issuer" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.todoapp_eks_cluster.identity[0].oidc[0].issuer
}

output "eks_cluster_certificate" {
  value = aws_eks_cluster.todoapp_eks_cluster.certificate_authority[0].data
}