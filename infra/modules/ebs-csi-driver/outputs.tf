output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver IAM Role"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}
