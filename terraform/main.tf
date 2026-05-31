provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "diploma-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  
  database_subnets= ["10.0.3.0/24", "10.0.4.0/24"]
  
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  
  create_database_subnet_group = true

  tags = {
    Project = "Diploma-CI-CD"
  }
} 


resource "aws_ecr_repository" "app_repo" {
  name                 = "diploma-app-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true 

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}