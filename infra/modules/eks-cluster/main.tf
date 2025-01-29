resource "aws_iam_role" "todoapp_eks_cluster_role" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_eks_cluster_auth" "todoapp-eks-cluster" {
  name = var.cluster_name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.todoapp_eks_cluster_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "todoapp_eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.todoapp_eks_cluster_role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = var.subnet_ids
  }

  tags    = merge(var.tags, { Name = "${var.project_name}-${var.environment}-eks-cluster" })
  version = var.eks_version

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}
