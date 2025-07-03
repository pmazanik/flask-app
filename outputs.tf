output "eks_cluster_name" {
    value = module.eks.cluster_name
}

output "ecr_repository_url" {
    value = aws_ecr_repository.flask_app.repository_url
}