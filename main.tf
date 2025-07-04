# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "= 5.95.0"
#     }
#   }
#   required_version = "< 6.0.0"
# }

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.21.0"

    name = "eks-vpc"
    cidr = "10.0.0.0/16"

    azs = ["eu-central-1a", "eu-central-1b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

    enable_nat_gateway  = true
    single_nat_gateway  = true
    enable_vpn_gateway = false

    tags = {
        "kubernetes-cluster" = "eks-demo"
    }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.37.1"
    cluster_name = "eks-demo"
    cluster_version = "1.29"
    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id

    cluster_endpoint_public_access  = true     # Доступ к API-серверу EKS снаружи (ИНТЕРНЕТ)
    cluster_endpoint_private_access = true     # Одновременно доступ из VPC

    authentication_mode = "API_AND_CONFIG_MAP"  # <--- Новое!
    enable_cluster_creator_admin_permissions = true # <--- Разрешить IAM юзеру-creator доступ system:masters

    # # Новый способ добавлять пользователей/роли:
    # access_entries = {
    # admin_user = {
    #     principal_arn = "arn:aws:iam::869697816139:user/pmz"
    #     policy_associations = {
    #     admin = {
    #         policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    #         access_scope = {
    #         type       = ""
    #         namespaces = []
    #         }
    #     }
    #     }
    # }
    # }


    eks_managed_node_group_defaults = {
        instance_types = ["t3.small"]
    }

    eks_managed_node_groups = {
        default = {
            min_size = 2
            max_size = 3
            desired_size = 2
        }
    }
    tags = {
        "kubernetes-cluster" = "eks-demo"
    }

}

resource "aws_ecr_repository" "flask_app" {
    name = "flask-app"
    image_tag_mutability = "MUTABLE"
    force_delete = true
}