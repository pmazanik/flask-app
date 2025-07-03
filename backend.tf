terraform {
    backend "s3" {
        bucket = "pmz-eks-terraform-state-bucket"
        key = "eks/terraform.tfstate"
        region = "eu-central-1"
    }
}