# module "eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   version         = "17.24.0"
#   cluster_name    = "AP_EKS_Cluster"
#   cluster_version = "1.20"
#   subnets         = var.private_subnet

#   vpc_id = var.utopia_vpc_id

#   fargate_profiles = {
#     default = {
#       name = "default"
#       selectors = [
#         {
#           namespace = "kube-system"
#           labels = {
#             k8s-app = "kube-dns"
#           }
#         },
#         {
#           namespace = "default"
#         }
#       ]

#       tags = {
#         Owner = "test"
#       }

#       timeouts = {
#         create = "20m"
#         delete = "20m"
#       }
#     }
#   }
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }
