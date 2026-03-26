terraform {
  required_version = ">=1.10"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "serverless-order-mgmt-tfstate-bucket"
    key = "serverless-order-mgmt/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
    region = var.aws_region
}
