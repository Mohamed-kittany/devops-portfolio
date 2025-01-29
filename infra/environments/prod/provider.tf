# terraform {
#   backend "s3" {
#     bucket = "mohamed-terraform-todoapp"
#     key    = "todoapp/prod/terraform.tfstate"
#     region = "ap-south-1"
#     dynamodb_table = "mohamed-terraform-lock-table"
#     encrypt        = true
#   }
# }

# provider "aws" {
#   region = var.region

#   default_tags {
#     tags = {
#       owner           = "mohamed.kittany"
#       bootcamp        = "BC22"
#       expiration_date = "01-03-2025"
#     }
#   }
# }

# # # TLS needed for the thumbprint
# provider "tls" {}

# # provider "kubernetes" {
# #   config_path = "~/.kube/config"
# # }

# provider "kubernetes" {
#   host                   = module.eks_cluster.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate)
#   token                  = data.aws_eks_cluster_auth.todoapp-eks-cluster.token
# }

# // Change the place of this data/resource
# data "aws_eks_cluster_auth" "todoapp-eks-cluster" {
#   name = var.cluster_name
# }